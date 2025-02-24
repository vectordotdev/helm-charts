#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <GitHub issue link>"
  exit 1
fi

ISSUE_LINK=$1

# Ensure we are on the develop branch
git switch develop
git pull

# Step 1: Run .github/release-vector-version.sh
VERSION=$(grep 'version:' charts/vector/Chart.yaml | awk '{print $2}')
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
git push -u origin "$BRANCH1"
PR1_URL=$(gh pr create \
  --title "feat(vector): Update Vector version to $VERSION and Helm docs" \
  --body "This PR updates the Vector chart version to $VERSION and regenerates Helm docs.\n\nRef: $ISSUE_LINK" \
  --base master --head "$BRANCH1" --json url -q .url)

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
PR2_URL=$(gh pr create \
  --title "feat(vector): Regenerate CHANGELOG for $VERSION" \
  --body "This PR regenerates the CHANGELOG for the $VERSION release.\n\nRef: $ISSUE_LINK" \
  --base master --head "$BRANCH2" --json url -q .url)

echo "PR for Step 3 submitted: $PR2_URL"

# Wait for PR1 to be merged
echo "Waiting for PR1 ($PR1_URL) to be merged..."
while ! gh pr view "$PR1_URL" --json merged -q .merged | grep -q true; do
  sleep 10
done

echo "PR1 ($PR1_URL) merged."

# Wait for PR2 to be merged
echo "Waiting for PR2 ($PR2_URL) to be merged..."
while ! gh pr view "$PR2_URL" --json merged -q .merged | grep -q true; do
  sleep 10
done

echo "PR2 ($PR2_URL) merged."

# Final Step: Merge develop into master
git switch master
git pull
git merge develop
git push

echo "Release workflow initiated: https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml"
