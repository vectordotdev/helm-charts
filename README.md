# Vector Helm Charts

Official Helm charts for Vector. Currently supported:
- [Vector](charts/vector/README.md) (vector/vector)
- [Vector Agents](charts/vector-agent/README.md) (vector/vector-agent)
- [Vector Aggregators](charts/vector-aggregator/README.md) (vector/vector-aggregator)

*Note*: The [helm charts in the `vector` repository](https://github.com/vectordotdev/vector/tree/master/distribution/helm) are being deprecated in favor of the ones here. In addition, consider trying out the experimental [Vector chart](charts/vector/README.md) for your deployment!

# How to use the Vector Helm Repository

You need to add this repository to your Helm repositories:

```shell
helm repo add vector https://helm.vector.dev
helm repo update
```

# Releasing

Charts are packaged and released with [`cr`](https://github.com/helm/chart-releaser) when the `develop` branch is merged into `master`.
