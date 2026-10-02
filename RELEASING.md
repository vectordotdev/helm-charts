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
