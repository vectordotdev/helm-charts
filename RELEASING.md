# Releasing

This document is intended for project maintainers.

Charts are packaged and released with [`cr`](https://github.com/helm/chart-releaser) when the `develop` branch is merged into `master`.

## Prerequisites

The release workflows authenticate as the `vectordotdev-bot` GitHub App. The App must be installed on this repo, with the following configured under **Settings → Secrets and variables → Actions**:

- Variable: `VECTORDOTDEV_BOT_APP_ID` — the App's numeric ID.
- Secret: `VECTORDOTDEV_BOT_PRIVATE_KEY` — the App's private key (PEM contents).

The App is required because the default `GITHUB_TOKEN` cannot trigger downstream workflows — without it, the push to `master` would not fire the [release workflow](https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml), and PR-creation events would not run CI.

## Automated release

1. Go to **Actions → Prepare Release** and click **Run workflow**, or run:
   ```shell
   gh workflow run release-prepare.yml
   ```
2. Review the opened release PR — edit `CHANGELOG.md` if needed, then **squash-merge** into `develop`.
3. The **Post Release** workflow fires automatically on merge and:
   - Merges `develop` into `master` (triggering the chart release).
   - Opens a version bump PR for the next development cycle, set to auto-merge once CI passes.

Once the [release workflow](https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml) completes, the chart is published.

## Releasing manually

<details>
<summary>Use this only if the automated workflows fail.</summary>

1. Run `.github/release-vector-version.sh` to update the Vector image version, then run `helm-docs`.
  - Commit: `feat(vector): Bump Vector to <version> and update Helm docs`

2. Run `.github/release-changelog.sh` to regenerate the CHANGELOG.
  - Commit: `feat(vector): Regenerate CHANGELOG for <version>`

3. Submit both commits as a single PR to `develop` and merge it.

4. Merge `develop` into `master` to trigger the release workflow:
   ```shell
   git switch master && git pull
   git merge develop
   git push
   ```

5. Bump the chart minor version in `charts/vector/Chart.yaml`, run `helm-docs`, and open a PR to `develop`.

</details>
