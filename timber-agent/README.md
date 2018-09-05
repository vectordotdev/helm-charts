# Timber Agent Helm Chart

Installs the Timber Agent as a DaemonSet on Kubernetes
More info about can be found [here](https://timber.io/docs/platforms/kubernetes)

## Prerequisites

- Kubernetes 1.6+

## Installing the Chart

To install the chart with the release name `my-release`:

_Assumes the timber/helm-charts repo is added as timber._

```bash
helm install --name my-release \
  --set timber.apiKey=TIMBER_API_KEY \
  timber/timber-agent
```

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```bash
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

| Parameter                   | Description                         | Default                                           |
|-----------------------------|-------------------------------------|---------------------------------------------------|
| `image.repository`          | Image repository | `timberio/agent` |
| `image.tag`                 | Image tag (`Must be >= 0.8.0`) | `0.9.2`|
| `image.pullPolicy`          | Image pull policy | `IfNotPresent` |
| `podAnnotations`            | Key value pairs to store as Pod metadata | `{}`
| `daemonsetTolerations`      | List of accepted node taints | `[]`
| `updateStrategy`            | Strategy for DaemonSet updates (requires Kubernetes >= 1.6) | `OnDelete`
| `rbac.create`               | Controls whether RBAC resources are created | `true`
| `resources.limits.cpu`      | Pod CPU limit in MHz (m) | |
| `resources.limits.memory`   | Pod Memory limit in MiB (Mi) | |
| `resources.requests.cpu`    | Pod CPU request in MHz (m) | |
| `resources.requests.memory` | Pod Memory request in MiB (Mi)| |
| `serviceAccount.create`     | Controls whether a new service account name is created | `true`
| `serviceAccount.name`       | Service account to use. If not set and `serviceAccount.create` is `true` a name is generated using the fullname template. |  |
| `timber.config`             | TOML document for setting the Timber Agent configuration | See [values.yaml](values.yaml)
| `timber.proxyImage`         | Image containing kubectl binary used to run `kubectl proxy` | `timberio/kubectl:1.10.0`
| `timber.proxyHost`          | Address Kubernetes API proxy listens on | `localhost`
| `timber.proxyPort`          | Port Kubernetes API proxy listens on | `8001`
