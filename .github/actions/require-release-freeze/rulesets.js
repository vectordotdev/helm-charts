// Branches the release pushes to directly while the freeze is active.
const RELEASE_BRANCHES = ["master", "develop"];

function readRulesetIds(env) {
  const parseId = (value, variable) => {
    const text = value?.trim();
    const id = Number(text);
    if (!/^[1-9]\d*$/.test(text ?? "") || !Number.isSafeInteger(id)) {
      throw new Error(`${variable} must contain positive integer ruleset IDs.`);
    }
    return id;
  };
  const freezeId = parseId(env.RELEASE_FREEZE_RULESET_ID, "RELEASE_FREEZE_RULESET_ID");
  const bypassIds = (env.RELEASE_FREEZE_BOT_BYPASS ?? "")
    .split(",")
    .map((value) => parseId(value, "RELEASE_FREEZE_BOT_BYPASS"));
  if (bypassIds.includes(freezeId)) {
    throw new Error(
      "RELEASE_FREEZE_BOT_BYPASS must not include RELEASE_FREEZE_RULESET_ID; its bypasses stay unchanged."
    );
  }
  if (new Set(bypassIds).size !== bypassIds.length) {
    throw new Error("RELEASE_FREEZE_BOT_BYPASS must not contain duplicate ruleset IDs.");
  }
  return { freezeId, bypassIds };
}

const releaseRef = (ref, branch, defaultBranch) =>
  ref === `refs/heads/${branch}` || (ref === "~DEFAULT_BRANCH" && branch === defaultBranch);

// Only exact release branch scopes are safe to modify: a bypass on a wildcard
// or broader ruleset would also grant access outside the release branches.
function targetsOnlyReleaseBranches(ruleset, defaultBranch) {
  const refs = ruleset.conditions?.ref_name;
  return (
    ruleset.target === "branch" &&
    refs?.include?.length > 0 &&
    refs.include.every((ref) => RELEASE_BRANCHES.some((branch) => releaseRef(ref, branch, defaultBranch))) &&
    refs.exclude?.length === 0
  );
}

function isBotActor(actor, appId) {
  return actor.actor_type === "Integration" && actor.actor_id === appId;
}

function hasBotBypass(ruleset, appId) {
  return ruleset.bypass_actors?.some(
    (actor) => isBotActor(actor, appId) && ["always", "exempt"].includes(actor.bypass_mode)
  );
}

// Identity comes from configuration, not the ruleset's name or bypass actors.
// The freeze must cover every release branch, not only some of them.
function restrictsReleaseUpdates(ruleset, defaultBranch) {
  const include = ruleset.conditions?.ref_name?.include ?? [];
  return (
    ruleset.source_type === "Repository" &&
    targetsOnlyReleaseBranches(ruleset, defaultBranch) &&
    RELEASE_BRANCHES.every((branch) => include.some((ref) => releaseRef(ref, branch, defaultBranch))) &&
    ruleset.rules?.some((rule) => rule.type === "update" && rule.parameters?.update_allows_fetch_and_merge !== true)
  );
}

// The bot may bypass only the rules that stop a direct push. Required status
// checks are deliberately absent: GitHub must keep enforcing them on every push.
function isReleasePolicy(ruleset, defaultBranch) {
  const allowed = ["pull_request", "update"];
  return (
    ruleset.source_type === "Repository" &&
    targetsOnlyReleaseBranches(ruleset, defaultBranch) &&
    ruleset.rules?.length > 0 &&
    ruleset.rules.every((rule) => allowed.includes(rule.type))
  );
}

// Granting a bypass requires the policy to be in force; revoking one does not.
function canManageReleaseBypass(ruleset, defaultBranch) {
  return ruleset.enforcement === "active" && isReleasePolicy(ruleset, defaultBranch);
}

module.exports = {
  RELEASE_BRANCHES,
  readRulesetIds,
  isBotActor,
  hasBotBypass,
  restrictsReleaseUpdates,
  isReleasePolicy,
  canManageReleaseBypass
};
