# Vector

![Version: 0.1.0-alpha.0](https://img.shields.io/badge/Version-0.1.0--alpha.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.16.1-distroless-libc](https://img.shields.io/badge/AppVersion-0.16.1--distroless--libc-informational?style=flat-square)

[Vector](https://vector.dev/) is a high-performance, end-to-end observability data pipeline that puts you in control of your observability data. Collect, transform, and route all your logs, metrics, and traces to any vendors you want today and any other vendors you may want tomorrow. Vector enables dramatic cost reduction, novel data enrichment, and data security where you need it, not where is most convenient for your vendors.

## How to use Vector Helm repository

You need to add this repository to your Helm repositories:

```
helm repo add vector https://helm.vector.dev
helm repo update
```

## Prerequisites

Kubernetes 1.15+

## Quick start

By default, Vector runs in the Aggregator role. It can alternatively run as a DaemonSet for the Agent role.

### Installing the Vector chart

To install the chart with the release name `<RELEASE_NAME>` run:

```bash
helm install --name <RELEASE_NAME> \
  vector/vector
```

### Upgrading

TODO

### Uninstalling the Chart

To uninstall/delete the `<RELEASE_NAME>` deployment:

```bash
helm delete <RELEASE_NAME> --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

1. Using our [`default-values.yaml`](values.yaml) configuration file as a reference, create your own `values.yaml`.
1. Upgrade the Vector chart with your new `values.yaml` file:

```bash
helm upgrade -f values.yaml <RELEASE_NAME> vector/vector
```

**Vector recommends that your `values.yaml` only contain values that need to be overridden, as it allows a smoother experience when upgrading chart versions.**

See the [All configuration options](#all-configuration-options) section to discover all possibilities offered by the Vector chart.

## All configuration options

The following table lists the configurable parameters of the Vector chart and their default values. Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
helm install --name <RELEASE_NAME> \
  --set role=Agent \
  vector/vector
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Allow Vector to schedule using affinity rules |
| customConfig | object | `{}` | Override Vector's default configs, if used **all** options need to be specified |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"timberio/vector"` |  |
| image.tag | string | `""` |  |
| livenessProbe | object | `{}` | Override default liveness probe settings |
| nodeSelector | object | `{}` | Allow Vector to be scheduled on selected nodes |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Specifies the accessModes for PersistentVolumeClaims |
| persistence.enabled | bool | `false` | If true, create and use PersistentVolumeClaims |
| persistence.finalizers | list | `["kubernetes.io/pvc-protection"]` | Specifies the finalizers of PersistentVolumeClaims |
| persistence.selectors | object | `{}` | Specifies the selectors for PersistentVolumeClaims |
| persistence.size | string | `"10Gi"` | Specifies the size of PersistentVolumeClaims |
| podSecurityContext | object | `{}` | Allows you to overwrite the default PodSecurityContext on the Daemonset or StatefulSet |
| rbac.create | bool | `true` | If true, create and use RBAC resources |
| readinessProbe | object | `{}` | Override default readiness probe settings, if customConfig is used require customConfig.api.enabled true |
| resources | object | `{}` | Vector resource requests and limits. |
| role | string | `"Aggregator"` | Role for this deployment (possible values: Agent, Aggregator) |
| securityContext | object | `{}` | Specify securityContext on the vector container |
| service.enabled | bool | `true` | If true, create and use a Service resource |
| serviceAccount.create | bool | `true` | If true, create ServiceAccount, require rbac rbac.create true |
| serviceAccount.name | string | `nil` | The name of the ServiceAccount to use. |
| tolerations | list | `[]` | Allow Vector to schedule on tainted nodes (requires Kubernetes >= 1.6) |
