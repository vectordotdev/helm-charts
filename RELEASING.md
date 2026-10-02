# Releasing

This document is intended for project maintainers.

Charts are packaged and released with [`cr`](https://github.com/helm/chart-releaser) when `master` fast-forwards to a release commit on `develop`.

## Prerequisites

The release workflows authenticate as the `vectordotdev-bot` GitHub App. The App must be installed on this repo with **Contents** write, **Actions** read, and **Administration** write (to update rulesets) permissions. It does not need **Workflows** write: GitHub checks that permission only for new commits, the release creates commits that change only release files, and `master` fast-forwards to commits that already exist on `develop`.

Configure the following under **Settings → Secrets and variables → Actions**:

- Secret: `VECTORDOTDEV_BOT_APP_ID` — the App's numeric ID.
- Secret: `VECTORDOTDEV_BOT_PRIVATE_KEY` — the App's private key (PEM contents).
- Variable: `RELEASE_FREEZE_RULESET_ID` — the ID of the release freeze ruleset.
- Variable: `RELEASE_FREEZE_BOT_BYPASS` — comma-separated IDs of the rulesets that the App bypasses during the freeze.

The App is required because the default `GITHUB_TOKEN` cannot trigger downstream workflows — without it, the push to `master` would not fire the [release workflow](https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml), and the pushes to `releasing/` branches would not run CI.

### Rulesets

The release does not use pull requests: it pushes directly to `master` and `develop`. A release freeze limits these pushes to the release window, and the required status checks stay in force for them:

| Ruleset | Rules | Bypass list |
| --- | --- | --- |
| Release freeze (`RELEASE_FREEZE_RULESET_ID`) | **Restrict updates** on `master` and `develop`. **Disabled** outside a release. | `vectordotdev-bot` with **Always**. No one else: the release does not need human merges. |
| Pull request and update policy (`RELEASE_FREEZE_BOT_BYPASS`) | Only **Require a pull request** and **Restrict updates**, on `master` and/or `develop` only. | The freeze gives `vectordotdev-bot` a temporary **Always** bypass and removes it when the freeze closes. |
| Required status checks | **Require status checks to pass**, and other rules such as **Require linear history**. | Never `vectordotdev-bot`. |
| Force-push and deletion protection | **Block force pushes** and **Restrict deletions**. | None. |

Before it activates the freeze, Prepare Release makes sure that the rulesets agree with this table. Every push also makes sure that the freeze is active and that the App cannot bypass the required status checks.

### Branch history

`master` only fast-forwards along `develop`, so `master` must always be an ancestor of `develop`. Do not commit to `master` directly: Post Release fails if `master` has commits that `develop` does not have.

## Automated release

The Vector release workflow starts **Prepare Release** on `develop` for each Vector release. To start it yourself, go to **Actions → Prepare Release** and click **Run workflow**, or run:

```shell
gh workflow run release-prepare.yml
```

No one reviews the release. To correct `CHANGELOG.md`, open a normal PR after the release.

1. **Prepare Release**:
   - Finds the highest stable Vector version (`vX.Y.Z`).
   - Activates the release freeze: only `vectordotdev-bot` can update `master` and `develop`.
   - Commits the new `appVersion` with the Helm docs, then the regenerated `CHANGELOG.md`, and pushes both commits to `develop`.
   - Starts Post Release with the release commit.
2. **Post Release**:
   - Fast-forwards `master` to the release commit (triggering the chart release). CI already passed on that commit, so it does not run again.
   - Bumps the chart version on `develop` for the next development cycle.
   - Closes the freeze.

Before each direct push, the workflow makes sure that [Lint and Test Charts](https://github.com/vectordotdev/helm-charts/actions/workflows/ci.yaml) passed on that exact commit. For a new commit, it first pushes the commit to a `releasing/` branch and waits for CI. Only then does it push the commit to `master` or `develop`.

If a step fails, the freeze stays active so that a retry can push. Re-run the failed workflow, or run [Unfreeze release branches](https://github.com/vectordotdev/helm-charts/actions/workflows/release-unfreeze.yml) to abandon the release. A re-run of Prepare Release finds the release commit that it already pushed and starts Post Release again. To run Post Release yourself, give it the `feat(vector): Regenerate CHANGELOG for <version>` commit on `develop`.

Once the [release workflow](https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml) completes, the chart is published.

## Releasing manually

<details>
<summary>Use this only if the automated workflows fail.</summary>

1. Run `.github/release-vector-version.sh <vector version>` to update the Vector image version, then run `helm-docs`.
  - Commit: `feat(vector): Bump Vector to <version> and update Helm docs`

2. Run `.github/release-changelog.sh` to regenerate the CHANGELOG.
  - Commit: `feat(vector): Regenerate CHANGELOG for <version>`

3. Push both commits to `develop` through a `releasing/` branch, and push them to `develop` only after Lint and Test Charts passes on them:
   ```shell
   git push origin HEAD:refs/heads/releasing/release-<chart version>
   # Wait for Lint and Test Charts to pass on releasing/release-<chart version>.
   git push origin HEAD:refs/heads/develop
   git push origin --delete releasing/release-<chart version>
   ```

4. Fast-forward `master` to the release commit to trigger the release workflow. CI already passed on it in step 3:
   ```shell
   git push origin HEAD:refs/heads/master
   ```

5. Bump the chart minor version in `charts/vector/Chart.yaml`, run `helm-docs`, and push the commit to `develop` the same way as step 3, through `releasing/bump-<next version>`.

6. If the freeze is still active, run [Unfreeze release branches](https://github.com/vectordotdev/helm-charts/actions/workflows/release-unfreeze.yml).

</details>
