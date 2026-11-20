# Releasing

This document is intended for project maintainers.

Charts are packaged and released with [`cr`](https://github.com/helm/chart-releaser) when `master` fast-forwards to a release commit on `develop`.

`master` only fast-forwards along `develop`, so `master` must always be an ancestor of `develop`. Do not commit to `master` directly: Post Release fails if `master` has commits that `develop` does not have.

## Automated release

The Vector release workflow starts **Prepare Release** on `develop` for each Vector release. To start it yourself, go to **Actions → Prepare Release** and click **Run workflow**, or run:

```shell
gh workflow run release-prepare.yml
```

If a workflow fails, re-run it or run [Unfreeze release branches](https://github.com/vectordotdev/helm-charts/actions/workflows/release-unfreeze.yml) to abandon the release.

## Releasing manually

<details>
<summary>Use this if the automated workflows fail, or for a chart-only patch release.</summary>

Do not use **Prepare Release** for a chart-only patch release (a new chart version with the same Vector version). It only releases new Vector versions.

`develop` accepts changes only through pull requests, which need one approval and a linear history. Merge release pull requests with **Rebase and merge** so that the commit subjects stay exact. Pushing to `master` requires bypass permission on its rulesets, which repository admins have.

1. From an up-to-date `develop`, create a branch and update the version:
   - **Vector release:** run `.github/release-vector-version.sh <vector version>`, then `helm-docs`.
     Commit: `feat(vector): Bump Vector to <vector version> and update Helm docs`
   - **Chart-only patch release:** set `version` in `charts/vector/Chart.yaml` to the patch version, for example `"0.62.1"`. Keep the quotes: the release workflows require them. Then run `helm-docs`.
     Commit: `chore(releasing): Set chart version to <chart version>`

2. Run `.github/release-changelog.sh`, which needs `yq` and `git-cliff`. Review the new entry: git-cliff lists every commit since the last release tag. For a patch release, remove the `Bump chart version to <next version>` entry from the previous release. If the release has a breaking change, write the upgrade steps under its entry.
   - **Vector release:** commit `feat(vector): Regenerate CHANGELOG for <vector version>`
   - **Chart-only patch release:** commit `feat(vector): Regenerate CHANGELOG for chart <chart version>`. Prepare Release identifies a finished release by the subject `Regenerate CHANGELOG for <vector version>`, so a patch release must not use that subject.

3. Open a pull request to `develop` and merge it after CI passes. CI compares the chart against `master`. For a patch release, `install-chart` also installs the version on `master` and upgrades it to the new version (chart-testing skips this upgrade test for a minor version bump). If that upgrade test fails, the release breaks upgrades from the last release. Bypass the check only if the break is intended and the changelog documents it.

4. Fast-forward `master` to the release commit, which is the merged changelog commit on `develop`. This starts [Release Charts](https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml), which publishes the chart:
   ```shell
   git fetch origin
   git log --oneline origin/master..origin/develop  # Check what will be released.
   git push origin <release commit>:refs/heads/master
   gh release view vector-<chart version>
   ```

5. Open a pull request to `develop` that sets `version` to the next minor version (`<major>.<minor + 1>.0`) and runs `helm-docs`.
   Commit: `chore(releasing): Bump chart version to <next version>`
   Merge it before the next release and before other chart changes: until then, `develop` has the same chart version as `master`, and `lint-chart` fails on chart changes.

6. If the freeze is still active, run [Unfreeze release branches](https://github.com/vectordotdev/helm-charts/actions/workflows/release-unfreeze.yml).

</details>
