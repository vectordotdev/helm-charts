#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <GitHub issue link>"
  exit 1
fi

tools=("helm-docs" "gh" "yq" "git-cliff" "git" "curl" "awk" "sed")

for tool in "${tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "❌ $tool is missing. See README.md for all required tools"
        exit 1
    fi
done

ISSUE_LINK=$1
VECTOR_VERSION=$(curl --silent https://api.github.com/repos/vectordotdev/vector/releases/latest \
  | grep -oE "tag_name\": *\".{1,15}\"," \
  | ${SED:-sed} 's/tag_name\": *\"v//;s/\",//')

create_pr() {
  local branch title output pr_url
  branch="$1"
  title="$2"
  body="${3:-Ref: $ISSUE_LINK}"

  output=$(gh pr create \
    --title "$title" \
    --body "$body" \
    --base develop --head "$branch")

  pr_url=$(echo "$output" | tail -n 1)
  echo "$pr_url"
}

green() {
  printf '\033[32m%s\033[0m\n' "$1"
}

purple() {
  printf '\033[35m%s\033[0m\n' "$1"
}

wait_for_pr_merge() {
  local pr_url="$1"

  echo "Waiting for PR ($pr_url) to be merged..."

  while [[ -z $(gh pr view "$pr_url" --json mergedAt -q .mergedAt) ]]; do
    sleep 10
  done

  purple "PR ($pr_url) has been merged!"
}

# Ensure we are on the develop branch
git switch develop
git pull

# Step 1: Run .github/release-vector-version.sh
BRANCH1="update-vector-version-$VECTOR_VERSION"
git checkout -b "$BRANCH1"
.github/release-vector-version.sh

# Step 2: Update Helm docs
helm-docs

# Commit changes from Steps 1 and 2
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m \
    "feat(vector): Bump Vector to $VECTOR_VERSION and update Helm docs"
  echo "Committed changes from Steps 1 and 2."
  git push -u origin "$BRANCH1"
else
  echo "No changes to commit from Steps 1 and 2."
  exit 1
fi

# Push the branch and submit a PR for Steps 1 and 2
PR1_URL=$(create_pr "$BRANCH1" "feat(releasing): Update Vector version to $VECTOR_VERSION and Helm docs")
green "PR for Steps 1 & 2 submitted: $PR1_URL"
wait_for_pr_merge "$PR1_URL"

# Step 3: Run .github/release-changelog.sh
git switch develop
git pull

BRANCH2="regenerate-changelog-$VECTOR_VERSION"
git checkout -b "$BRANCH2"
.github/release-changelog.sh

# Commit changes from Step 3
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m \
    "feat(vector): Regenerate CHANGELOG for $VECTOR_VERSION"
  echo "Committed changes from Step 3."
  git push -u origin "$BRANCH2"
else
  echo "No changes to commit from Step 3."
  exit 1
fi

# Push the branch and submit a PR for Step 3
CHART_VERSION=$(awk -F': ' '/version:/ {gsub(/"/, "", $2); print $2}' charts/vector/Chart.yaml)
PR2_URL=$(create_pr "$BRANCH2" "chore(vector): Regenerate CHANGELOG for $CHART_VERSION")
green "PR for Step 3 submitted: $PR2_URL"

# Both PRs needs to be merged before updating the master branch.
wait_for_pr_merge "$PR2_URL"

# Final Step: Merge develop into master
git fetch
git switch master
git pull
git merge develop
git push

echo "Release workflow initiated: https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml"

# Post Release Step
git switch develop
NEW_CHART_VERSION=$(echo "$CHART_VERSION" | awk -F. '{ $2++; $3=0; print $1"."$2"."$3 }')
BRANCH3="bump-chart-version-$NEW_CHART_VERSION"

# MacOS sed doesn't support -i like all other implementations do
sed "/^version:/s|$CHART_VERSION|$NEW_CHART_VERSION|" charts/vector/Chart.yaml > charts/vector/Chart.yaml.tmp \
  && mv charts/vector/Chart.yaml.tmp charts/vector/Chart.yaml

git checkout -b "$BRANCH3"
message="chore(releasing): Bump chart version to $NEW_CHART_VERSION"

# Commit changes from Post Release Step
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "$message"
  echo "Committed changes from Post Release Step"
  git push -u origin "$BRANCH3"
else
  echo "No changes to commit from Post Release Step"
  exit 1
fi

PR3_URL=$(create_pr "$BRANCH3" "$message" "Post release version bump")
green "Post Release Step PR submitted: $PR3_URL"

wait_for_pr_merge "$PR3_URL"

echo "Make sure to monitor the release workflow if you aren't already: https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml"
