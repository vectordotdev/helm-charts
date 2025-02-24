#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <GitHub issue link>"
  exit 1
fi

ISSUE_LINK=$1
VERSION=$(awk -F': ' '/version:/ {gsub(/"/, "", $2); print $2}' charts/vector/Chart.yaml)

create_pr() {
  local branch output pr_url pr_number
  branch="$1"  # Read branch name from function argument

  output=$(gh pr create \
    --title "feat(vector): Update Vector version to $VERSION and Helm docs" \
    --body "This PR updates the Vector chart version to $VERSION and regenerates Helm docs.\n\nRef: $ISSUE_LINK" \
    --base master --head "$branch")

  echo "$output"  # Optional: Print the full output for debugging

  pr_url=$(echo "$output" | tail -n 1)  # Extract last line (PR URL)
  pr_number=$(basename "$pr_url")  # Extract PR number from URL

  echo "$pr_number"  # Return PR number via stdout
}

wait_for_pr_merge() {
  local pr_url="$1"

  echo "Waiting for PR ($pr_url) to be merged..."

  while [[ -z $(gh pr view "$pr_url" --json mergedAt -q .mergedAt) ]]; do
    sleep 10
  done

  echo "PR ($pr_url) has been merged!"
}

# Ensure we are on the develop branch
git switch develop
git pull

# Step 1: Run .github/release-vector-version.sh
BRANCH1="update-vector-version-$VERSION"
git checkout -b "$BRANCH1"
.github/release-vector-version.sh

# Step 2: Update Helm docs
helm-docs

# Commit changes from Steps 1 and 2
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m \
    "feat(vector): Bump Vector to $VERSION and update Helm docs"
  echo "Committed changes from Steps 1 and 2."
else
  echo "No changes to commit from Steps 1 and 2."
  exit 1
fi

# Push the branch and submit a PR for Steps 1 and 2
PR1_URL=$(create_pr "$BRANCH1")
echo "Submitted: $PR1_URL"

# Step 3: Run .github/release-changelog.sh
BRANCH2="regenerate-changelog-$VERSION"
git checkout -b "$BRANCH2" develop
.github/release-changelog.sh

# Commit changes from Step 3
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m \
    "feat(vector): Regenerate CHANGELOG for $VERSION"
  echo "Committed changes from Step 3."
else
  echo "No changes to commit from Step 3."
  exit 1
fi

# Push the branch and submit a PR for Step 3
git push -u origin "$BRANCH2"
PR2_URL=$(create_pr "$BRANCH2")

echo "PR for Step 3 submitted: $PR2_URL"

# Both PRs needs to be merged before updating the master branch.
wait_for_pr_merge "$PR1_URL"
wait_for_pr_merge "$PR2_URL"

# Final Step: Merge develop into master
git switch master
git pull
git merge develop
git push

echo "Release workflow initiated: https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml"
