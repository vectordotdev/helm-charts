# Vector

![Version: 0.1.0-beta.0](https://img.shields.io/badge/Version-0.1.0--beta.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.16.1-distroless-libc](https://img.shields.io/badge/AppVersion-0.16.1--distroless--libc-informational?style=flat-square)

[Vector](https://vector.dev/) is a high-performance, end-to-end observability data pipeline that puts you in control of your observability data. Collect, transform, and route all your logs, metrics, and traces to any vendors you want today and any other vendors you may want tomorrow. Vector enables dramatic cost reduction, novel data enrichment, and data security where you need it, not where is most convenient for your vendors.

## How to use Vector Helm repository

You need to add this repository to your Helm repositories:

```
helm repo add vector https://helm.vector.dev
helm repo update
```

## Requirements

Kubernetes: `>=1.15.0-0`

## Quick start

By default, Vector runs in the Aggregator role. It can alternatively run as a DaemonSet for the Agent role.

### Installing the Vector chart

To install the chart with the release name `<RELEASE_NAME>` run:

```bash
helm install --name <RELEASE_NAME> \
  vector/vector
```

### Upgrading

#### From original charts

* [Migrate from the `vector-agent` chart](docs/Migrate_from_vector-agent.md)
* [Migrate from the `vector-aggregator` chart](docs/Migrate_from_vector-aggregator.md)

### Uninstalling the chart

To uninstall/delete the `<RELEASE_NAME>` deployment:

```bash
helm delete <RELEASE_NAME>
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

### Vector values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Allow Vector to schedule using affinity rules |
| args | list | `["--config-dir","/etc/vector/"]` | Override Vector's default arguments |
| autoscaling.customMetric | object | `{}` | Target a custom metric |
| autoscaling.enabled | bool | `false` | Enabled autoscaling for the Stateless-Aggregator |
| autoscaling.maxReplicas | int | `10` | Maximum replicas for Vector's HPA |
| autoscaling.minReplicas | int | `1` | Minimum replicas for Vector's HPA |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization for Vector's HPA |
| autoscaling.targetMemoryUtilizationPercentage | int | `nil` | Target memory utilization for Vector's HPA |
| command | list | `[]` | Override Vector's default command |
| containerPorts | list | `[]` | Manually define Vector's Container ports, overrides automated generation of Container ports |
| customConfig | object | `{}` | Override Vector's default configs, if used **all** options need to be specified |
| dataDir | string | `""` | Specify the path for Vector's data, only used when existingConfig is used |
| dnsConfig | object | `{}` | Specify DNS configuration options for Vector Pods |
| dnsPolicy | string | `"ClusterFirst"` | Specify DNS policy for Vector Pods |
| env | list | `[]` | Set environment variables in Vector containers |
| existingConfig | string | `""` | Use this existing ConfigMap for Vector's configuration instead of creating a new one, if used requires dataDir to be set. Additionally, containerPorts and service.ports should be specified based on your supplied configuration |
| extraConfigs | list | `[]` | List of ConfigMap names to include as additional configuration files |
| fullnameOverride | string | `""` | Override the full qualified app name |
| image.pullPolicy | string | `"IfNotPresent"` | Vector image pullPolicy |
| image.pullSecrets | list | `[]` | Agent repository pullSecret (ex: specify docker registry credentials) |
| image.repository | string | `"timberio/vector"` | Override default registry + name for Vector |
| image.tag | string | Chart's appVersion | Vector image tag to use |
| ingress.annotations | object | `{}` | Set annotations on the Ingress |
| ingress.className | string | `""` | Specify the ingressClassName, requires Kubernetes >= 1.18 |
| ingress.enabled | bool | `false` | If true, create and use an Ingress resource |
| ingress.hosts | list | `[]` | Configure the hosts and paths for the Ingress |
| ingress.tls | list | `[]` | Configure TLS for the Ingress |
| livenessProbe | object | `{}` | Override default liveness probe settings, if customConfig is used requires customConfig.api.enabled true |
| nameOverride | string | `""` | Override name of app |
| nodeSelector | object | `{}` | Allow Vector to be scheduled on selected nodes |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Specifies the accessModes for PersistentVolumeClaims |
| persistence.enabled | bool | `false` | If true, create and use PersistentVolumeClaims |
| persistence.existingClaim | string | `""` | Name of an existing PersistentVolumeClaim to use |
| persistence.finalizers | list | `["kubernetes.io/pvc-protection"]` | Specifies the finalizers of PersistentVolumeClaims |
| persistence.hostPath.path | string | `"/var/lib/vector"` | Override path used for hostPath persistence |
| persistence.selectors | object | `{}` | Specifies the selectors for PersistentVolumeClaims |
| persistence.size | string | `"10Gi"` | Specifies the size of PersistentVolumeClaims |
| podAnnotations | object | `{}` | Set annotations on Vector Pods |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget for Vector |
| podDisruptionBudget.maxUnavailable | int | `1` | The number of Pods that can be unavailable after an eviction |
| podDisruptionBudget.minAvailable | int | `1` | The number of Pods that must still be available after an eviction |
| podLabels | object | `{}` | Set labels on Vector Pods |
| podManagementPolicy | string | `"OrderedReady"` | Specify the podManagementPolicy for the Aggregator role |
| podMonitor.enabled | bool | `false` | If true, create a PodMonitor for Vector |
| podMonitor.jobLabel | string | `"app.kubernetes.io/name"` | Override the label to retrieve the job name from |
| podMonitor.metricRelabelings | list | `[]` | MetricRelabelConfigs to apply to samples before ingestion |
| podMonitor.path | string | `"/metrics"` | Override the path to scrape |
| podMonitor.port | string | `"prom-exporter"` | Override the port to scrape |
| podMonitor.relabelings | list | `[]` | RelabelConfigs to apply to samples before scraping |
| podPriorityClassName | string | `""` | Set the priorityClassName on Vector Pods |
| podSecurityContext | object | `{}` | Allows you to overwrite the default PodSecurityContext for Vector |
| psp.create | bool | `false` | If true, create a PodSecurityPolicy resource. PodSecurityPolicy is deprecated as of Kubernetes v1.21, and will be removed in v1.25 |
| rbac.create | bool | `true` | If true, create and use RBAC resources. Only valid for the Agent role |
| readinessProbe | object | `{}` | Override default readiness probe settings, if customConfig is used requires customConfig.api.enabled true |
| replicas | int | `1` | Set the number of Pods to create |
| resources | object | `{}` | Set Vector resource requests and limits. |
| role | string | `"Aggregator"` | Role for this Vector (possible values: Agent, Aggregator, Stateless-Aggregator) |
| rollWorkload | bool | `true` | Add a checksum of the generated ConfigMap to workload annotations |
| secrets.generic | object | `{}` | Each Key/Value will be added to the Secret's data key |
| securityContext | object | `{}` | Specify securityContext on Vector containers |
| service.annotations | object | `{}` | Set annotations on Vector's Service |
| service.enabled | bool | `true` | If true, create and use a Service resource |
| service.ports | list | `[]` | Manually set Service ports, overrides automated generation of Service ports |
| service.topologyKeys | list | `[]` | Specify the topologyKeys field on Vector's Service spec |
| service.type | string | `"ClusterIP"` | Set type of Vector's Service |
| serviceAccount.annotations | object | `{}` | Annotations to add to the Vector ServiceAccount |
| serviceAccount.automountToken | bool | `true` | Automount API credentials for the Vector ServiceAccount |
| serviceAccount.create | bool | `true` | If true, create ServiceAccount |
| serviceAccount.name | string | `nil` | The name of the ServiceAccount to use. |
| terminationGracePeriodSeconds | int | `60` | Override Vector's terminationGracePeriodSeconds |
| tolerations | list | `[]` | Allow Vector to schedule on tainted nodes |
| updateStrategy | object | `{}` | Customize the updateStrategy used to replace Vector Pods |

### HAProxy values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| haproxy.affinity | object | `{}` | Allow HAProxy to schedule using affinity rules |
| haproxy.autoscaling.customMetric | object | `{}` | Target a custom metric |
| haproxy.autoscaling.enabled | bool | `false` | Enabled autoscaling for HAProxy |
| haproxy.autoscaling.maxReplicas | int | `10` | Maximum replicas for HAProxy's HPA |
| haproxy.autoscaling.minReplicas | int | `1` | Minimum replicas for HAProxy's HPA |
| haproxy.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization for HAProxy's HPA |
| haproxy.autoscaling.targetMemoryUtilizationPercentage | int | `nil` | Target memory utilization for HAProxy's HPA |
| haproxy.customConfig | string | `""` | Override HAProxy's default configs, if used **all** options need to be specified |
| haproxy.enabled | bool | `false` | If true, create a HAProxy load balancer |
| haproxy.existingConfig | string | `""` | Use this existing ConfigMap for HAProxy's configuration instead of creating a new one |
| haproxy.image.pullPolicy | string | `"IfNotPresent"` | HAProxy image pullPolicy |
| haproxy.image.pullSecrets | list | `[]` | HAProxy repository pullSecret (ex: specify docker registry credentials) |
| haproxy.image.repository | string | `"haproxytech/haproxy-alpine"` | Override default registry + name for HAProxy |
| haproxy.image.tag | string | `"2.4.4"` | HAProxy image tag to use |
| haproxy.nodeSelector | object | `{}` | Allow HAProxy to be scheduled on selected nodes |
| haproxy.podAnnotations | object | `{}` | Set annotations on HAProxy Pods |
| haproxy.podLabels | object | `{}` | Set labels on HAProxy Pods |
| haproxy.podPriorityClassName | string | `""` | Set the priorityClassName on HAProxy Pods |
| haproxy.podSecurityContext | object | `{}` | Allows you to overwrite the default PodSecurityContext for HAProxy |
| haproxy.replicas | int | `1` | Set the number of HAProxy Pods to create |
| haproxy.resources | object | `{}` | Set HAProxy resource requests and limits. |
| haproxy.rollWorkload | bool | `true` | Add a checksum of the generated ConfigMap to the HAProxy Deployment |
| haproxy.securityContext | object | `{}` | Specify securityContext on HAProxy containers |
| haproxy.service.topologyKeys | list | `[]` | Specify the topologyKeys field on HAProxy's Service spec |
| haproxy.service.type | string | `"ClusterIP"` | Set type of HAProxy's Service |
| haproxy.serviceAccount.annotations | object | `{}` | Annotations to add to the HAProxy ServiceAccount |
| haproxy.serviceAccount.automountToken | bool | `true` | Automount API credentials for the HAProxy ServiceAccount |
| haproxy.serviceAccount.create | bool | `true` | If true, create a HAProxy ServiceAccount |
| haproxy.serviceAccount.name | string | `nil` | The name of the HAProxy ServiceAccount to use. |
| haproxy.terminationGracePeriodSeconds | int | `60` | Override HAProxy's terminationGracePeriodSeconds |
| haproxy.tolerations | list | `[]` | Allow HAProxy to schedule on tainted nodes |
