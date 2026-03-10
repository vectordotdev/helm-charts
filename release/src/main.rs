use anyhow::{bail, Context, Result};
use serde::{Deserialize, Serialize};
use std::{fs, process::Command, thread, time::Duration};

const STATE_FILE: &str = ".release-state.json";
const GITHUB_API: &str =
    "https://api.github.com/repos/vectordotdev/vector/releases/latest";
const POLL_INTERVAL: Duration = Duration::from_secs(10);

/// Each variant is a stable checkpoint. The program saves state *after* completing
/// all work for a phase, so resuming always re-enters at a clean boundary.
#[derive(Debug, Serialize, Deserialize)]
#[serde(tag = "phase")]
enum Phase {
    /// Nothing done yet. Fetch version, create version-bump branch/PR.
    FetchVersion { issue_link: String },

    /// Version-bump PR created. Waiting for it to merge, then run changelog.
    WaitForVersionPr {
        issue_link: String,
        vector_version: String,
        pr_url: String,
    },

    /// Changelog PR created. Waiting for it to merge, then merge to master.
    WaitForChangelogPr {
        issue_link: String,
        vector_version: String,
        chart_version: String,
        pr_url: String,
    },

    /// Post-release version-bump PR created. Waiting for it to merge.
    WaitForBumpPr {
        issue_link: String,
        new_chart_version: String,
        pr_url: String,
    },

    Done,
}

fn issue_link_of(phase: &Phase) -> Option<&str> {
    match phase {
        Phase::FetchVersion { issue_link } => Some(issue_link),
        Phase::WaitForVersionPr { issue_link, .. } => Some(issue_link),
        Phase::WaitForChangelogPr { issue_link, .. } => Some(issue_link),
        Phase::WaitForBumpPr { issue_link, .. } => Some(issue_link),
        Phase::Done => None,
    }
}

// ── state file ───────────────────────────────────────────────────────────────

fn load_state() -> Option<Phase> {
    let content = fs::read_to_string(STATE_FILE).ok()?;
    serde_json::from_str(&content).ok()
}

fn save_state(phase: &Phase) -> Result<()> {
    fs::write(STATE_FILE, serde_json::to_string_pretty(phase)?)?;
    Ok(())
}

// ── shell helpers ─────────────────────────────────────────────────────────────

/// Run a command, inheriting stdout/stderr. Fails if exit code is non-zero.
fn run(program: &str, args: &[&str]) -> Result<()> {
    let status = Command::new(program)
        .args(args)
        .status()
        .with_context(|| format!("failed to spawn `{program}`"))?;
    if !status.success() {
        bail!("`{program} {}` exited with {status}", args.join(" "));
    }
    Ok(())
}

/// Run a command, capturing stdout. Fails if exit code is non-zero.
fn run_capture(program: &str, args: &[&str]) -> Result<String> {
    let output = Command::new(program)
        .args(args)
        .output()
        .with_context(|| format!("failed to spawn `{program}`"))?;
    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        bail!("`{program} {}` failed: {stderr}", args.join(" "));
    }
    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

fn check_tool(tool: &str) -> Result<()> {
    let ok = Command::new("sh")
        .args(["-c", &format!("command -v {tool}")])
        .status()
        .map(|s| s.success())
        .unwrap_or(false);
    if !ok {
        bail!("❌ {tool} is missing. See README.md for all required tools");
    }
    Ok(())
}

// ── domain helpers ────────────────────────────────────────────────────────────

fn fetch_vector_version() -> Result<String> {
    let response = ureq::get(GITHUB_API)
        .set("User-Agent", "helm-release")
        .call()
        .context("failed to fetch latest Vector release from GitHub")?;
    let json: serde_json::Value = response.into_json()?;
    let tag = json["tag_name"]
        .as_str()
        .context("tag_name missing from GitHub API response")?;
    Ok(tag.trim_start_matches('v').to_string())
}

fn read_chart_version() -> Result<String> {
    let content = fs::read_to_string("charts/vector/Chart.yaml")
        .context("failed to read charts/vector/Chart.yaml")?;
    for line in content.lines() {
        if let Some(rest) = line.strip_prefix("version:") {
            return Ok(rest.trim().trim_matches('"').to_string());
        }
    }
    bail!("version field not found in charts/vector/Chart.yaml")
}

fn bump_minor(version: &str) -> Result<String> {
    let parts: Vec<&str> = version.split('.').collect();
    if parts.len() != 3 {
        bail!("unexpected version format: {version}");
    }
    let major: u32 = parts[0].parse().context("invalid major version")?;
    let minor: u32 = parts[1].parse().context("invalid minor version")?;
    Ok(format!("{major}.{}.0", minor + 1))
}

fn bump_chart_yaml(old: &str, new: &str) -> Result<()> {
    let path = "charts/vector/Chart.yaml";
    let content = fs::read_to_string(path)?;
    let old_line = format!("version: \"{old}\"");
    let new_line = format!("version: \"{new}\"");
    if !content.contains(&old_line) {
        bail!("could not find `{old_line}` in {path}");
    }
    fs::write(path, content.replacen(&old_line, &new_line, 1))?;
    Ok(())
}

fn create_pr(branch: &str, title: &str, body: &str) -> Result<String> {
    let output = run_capture(
        "gh",
        &[
            "pr", "create",
            "--title", title,
            "--body", body,
            "--base", "develop",
            "--head", branch,
        ],
    )?;
    output
        .lines()
        .filter(|l| !l.is_empty())
        .last()
        .map(|s| s.to_string())
        .context("no output from `gh pr create`")
}

fn wait_for_merge(pr_url: &str) -> Result<()> {
    println!("Waiting for PR ({pr_url}) to be merged...");
    loop {
        let merged_at = run_capture(
            "gh",
            &["pr", "view", pr_url, "--json", "mergedAt", "-q", ".mergedAt"],
        )?;
        if !merged_at.is_empty() && merged_at != "null" {
            println!("\x1b[35mPR ({pr_url}) has been merged!\x1b[0m");
            return Ok(());
        }
        thread::sleep(POLL_INTERVAL);
    }
}

// ── state machine ─────────────────────────────────────────────────────────────

fn step(phase: Phase) -> Result<Phase> {
    match phase {
        Phase::FetchVersion { issue_link } => {
            let vector_version = fetch_vector_version()?;
            println!("Latest Vector version: {vector_version}");

            let branch = format!("update-vector-version-{vector_version}");

            // Step 1 & 2: version bump + helm-docs
            run("git", &["switch", "develop"])?;
            run("git", &["pull"])?;
            run("git", &["checkout", "-b", &branch])?;
            run(".github/release-vector-version.sh", &[])?;
            run("helm-docs", &[])?;

            if run_capture("git", &["status", "--porcelain"])?.is_empty() {
                bail!("no changes to commit from Steps 1 and 2");
            }
            run("git", &["add", "."])?;
            run(
                "git",
                &[
                    "commit", "-m",
                    &format!("feat(vector): Bump Vector to {vector_version} and update Helm docs"),
                ],
            )?;
            run("git", &["push", "-u", "origin", &branch])?;

            let pr_url = create_pr(
                &branch,
                &format!(
                    "feat(releasing): Update Vector version to {vector_version} and Helm docs"
                ),
                &format!("Ref: {issue_link}"),
            )?;
            println!("\x1b[32mPR for Steps 1 & 2 submitted: {pr_url}\x1b[0m");

            Ok(Phase::WaitForVersionPr {
                issue_link,
                vector_version,
                pr_url,
            })
        }

        Phase::WaitForVersionPr {
            issue_link,
            vector_version,
            pr_url,
        } => {
            wait_for_merge(&pr_url)?;

            // Step 3: changelog
            run("git", &["switch", "develop"])?;
            run("git", &["pull"])?;

            let branch = format!("regenerate-changelog-{vector_version}");
            run("git", &["checkout", "-b", &branch])?;
            run(".github/release-changelog.sh", &[])?;

            if run_capture("git", &["status", "--porcelain"])?.is_empty() {
                bail!("no changes to commit from Step 3");
            }
            run("git", &["add", "."])?;
            run(
                "git",
                &[
                    "commit", "-m",
                    &format!("feat(vector): Regenerate CHANGELOG for {vector_version}"),
                ],
            )?;
            run("git", &["push", "-u", "origin", &branch])?;

            let chart_version = read_chart_version()?;
            let pr_url = create_pr(
                &branch,
                &format!("chore(vector): Regenerate CHANGELOG for {chart_version}"),
                &format!("Ref: {issue_link}"),
            )?;
            println!("\x1b[32mPR for Step 3 submitted: {pr_url}\x1b[0m");

            Ok(Phase::WaitForChangelogPr {
                issue_link,
                vector_version,
                chart_version,
                pr_url,
            })
        }

        Phase::WaitForChangelogPr {
            issue_link,
            vector_version: _,
            chart_version,
            pr_url,
        } => {
            wait_for_merge(&pr_url)?;

            // Final step: merge develop → master
            run("git", &["fetch"])?;
            run("git", &["switch", "master"])?;
            run("git", &["pull"])?;
            run("git", &["merge", "develop"])?;
            run("git", &["push"])?;
            println!("Release workflow initiated: https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml");

            // Post-release: bump chart version
            run("git", &["switch", "develop"])?;
            let new_chart_version = bump_minor(&chart_version)?;
            let branch = format!("bump-chart-version-{new_chart_version}");
            run("git", &["checkout", "-b", &branch])?;

            bump_chart_yaml(&chart_version, &new_chart_version)?;
            run("helm-docs", &[])?;

            if run_capture("git", &["status", "--porcelain"])?.is_empty() {
                bail!("no changes to commit from Post Release Step");
            }
            let message = format!("chore(releasing): Bump chart version to {new_chart_version}");
            run("git", &["add", "."])?;
            run("git", &["commit", "-m", &message])?;
            run("git", &["push", "-u", "origin", &branch])?;

            let pr_url = create_pr(&branch, &message, "Post release version bump")?;
            println!("\x1b[32mPost Release Step PR submitted: {pr_url}\x1b[0m");

            Ok(Phase::WaitForBumpPr {
                issue_link,
                new_chart_version,
                pr_url,
            })
        }

        Phase::WaitForBumpPr { pr_url, .. } => {
            wait_for_merge(&pr_url)?;
            Ok(Phase::Done)
        }

        Phase::Done => Ok(Phase::Done),
    }
}

// ── main ──────────────────────────────────────────────────────────────────────

fn main() -> Result<()> {
    let issue_link = std::env::args()
        .nth(1)
        .context("Usage: helm-release <GitHub issue link>")?;

    for tool in &["helm-docs", "gh", "yq", "git-cliff", "git", "curl"] {
        check_tool(tool)?;
    }

    let mut phase = match load_state() {
        Some(Phase::Done) => {
            println!("Release already complete. Remove {STATE_FILE} to start a new release.");
            fs::remove_file(STATE_FILE).ok();
            return Ok(());
        }
        Some(p) if issue_link_of(&p) == Some(issue_link.as_str()) => {
            println!("\x1b[35mResuming release from saved state...\x1b[0m");
            p
        }
        Some(_) => {
            bail!(
                "State file {STATE_FILE} belongs to a different release. \
                 Remove it to start fresh."
            );
        }
        None => Phase::FetchVersion { issue_link },
    };

    loop {
        let next = step(phase)?;
        if matches!(next, Phase::Done) {
            fs::remove_file(STATE_FILE).ok();
            println!("Make sure to monitor the release workflow if you aren't already:");
            println!("https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml");
            break;
        }
        save_state(&next)?;
        phase = next;
    }

    Ok(())
}
