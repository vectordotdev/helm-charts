# Vector Helm Charts

Official Helm charts for Vector. Currently supported:
- [Vector](charts/vector/README.md) (vector/vector)
- **DEPRECATED** [Vector Agents](charts/vector-agent/README.md) (vector/vector-agent)
- **DEPRECATED** [Vector Aggregators](charts/vector-aggregator/README.md) (vector/vector-aggregator)

# How to use the Vector Helm Repository

You need to add this repository to your Helm repositories:

```shell
helm repo add vector https://helm.vector.dev
helm repo update
```

# Releasing

Charts are packaged and released with [`cr`](https://github.com/helm/chart-releaser)
when the `develop` branch is merged into `master`.

To make releasing easier two scripts have been included:

- `.github/release-vector-version.sh` queries [vectordotdev/vector](https://github.com/vectordotdev/vector)
for the latest release and updates the `vector` chart's default image. This is
convenient when updating the chart after a Vector release.
- `.github/release-changelog.sh` pulls the current `vector` chart version and
uses `git-cliff` to update the [CHANGELOG.md](CHANGELOG.md). Run this to generate
the final commit merged into `develop` before merging `develop` into `master`.
This script requires [`yq`](https://github.com/mikefarah/yq) to be installed.
