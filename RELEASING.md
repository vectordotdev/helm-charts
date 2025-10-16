# Releasing

This document is intended for project maintainers.

Charts are packaged and released with [`cr`](https://github.com/helm/chart-releaser) when the `develop` branch is merged into `master`.

Install the following required tools:
* [`helm-docs`](https://github.com/norwoodj/helm-docs)
* [`gh`](https://cli.github.com/)
* [`yq`](https://github.com/mikefarah/yq)
* [`git-cliff`](https://github.com/orhun/git-cliff)


Now run the release script:

```shell
bash release.sh <Vector release GitHub issue link>
```

This will create the pull requests and wait for them to be approved and merged. If the script fails, please refer to the following section and continue the release manually.

After the script runs, the [release workflow](https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml) should start automatically. Once it completes, you will have successfully released `helm-charts`!

## Releasing manually

<details>
<summary>Always prefer the automated method described above. Use this guide only if the above method fails. </summary>
To make releasing easier two scripts are utilized in the steps below.

1. Run `$ .github/release-vector-version.sh`
   - Update Helm docs by running `helm-docs`
   - Commit the changes generated from step 1. This needs to be a
      [conventional commit](https://www.conventionalcommits.org/).
     - E.g. "feat(vector): Bump Vector to v0.29.0"
     - Submit a PR with the changes.
   - Notes:
     - This queries [vectordotdev/vector](https://github.com/vectordotdev/vector)
     for the latest release and updates the `vector` chart's default image.
     - This is convenient when updating the chart after a Vector release.
     - On macOS, install `gsed`

2. Run `$ .github/release-changelog.sh`
   - Commit the changes generated from step 1. This needs to be a
      [conventional commit](https://www.conventionalcommits.org/).
      - E.g. "feat(vector): Regenerate CHANGELOG"
   - Submit a PR with the changes.
   - Notes:
     - This pulls the current `vector` chart version and uses `git-cliff` to update
       the [CHANGELOG.md](CHANGELOG.md). Run this to generate the final commit merged into
       `develop` before merging `develop` into `master`.
     - This script requires [`yq`](https://github.com/mikefarah/yq) and
       [`git-cliff`](https://github.com/orhun/git-cliff) to be installed.

3. To kick off the [release workflow](https://github.com/vectordotdev/helm-charts/actions/workflows/release.yaml):
 ```
   git switch master
   git pull
   git merge develop
   git push
```
</details>
