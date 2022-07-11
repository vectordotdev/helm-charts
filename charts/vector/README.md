# Vector

![Version: 0.14.0](https://img.shields.io/badge/Version-0.14.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.23.0-distroless-libc](https://img.shields.io/badge/AppVersion-0.23.0--distroless--libc-informational?style=flat-square)

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

By default, Vector runs as a `StatefulSet` in the "Aggregator" role. It can alternatively run as a `Deployment` for the "Stateless-Aggregator" role or a `DaemonSet` for the "Agent" role.

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

### Running on control plane nodes

Depending on your Kubernetes distribution, you may need to configure `tolerations` to run Vector on nodes acting as the control plane.

For example to run Vector on [Openshift](https://www.redhat.com/en/technologies/cloud-computing/openshift) control plane nodes you can set:

```yaml
tolerations:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
    operator: Exists
  - effect: NoSchedule
    key: node-role.kubernetes.io/infra
    operator: Exists
```

Or for [RKE](https://rancher.com/products/rke) control plane nodes set:

```yaml
tolerations:
  - effect: NoSchedule
    key: node-role.kubernetes.io/controlplane
    operator: Exists
  - effect: NoExecute
    key: node-role.kubernetes.io/etcd
    operator: Exists
```

### Using template syntax in `customConfig`

As Vector's [template syntax](https://vector.dev/docs/reference/configuration/template-syntax/) shares the same syntax as Helm templates, explicit handling is required
if you are using Vector's template syntax in the `customConfig` option. To avoid Helm templating configuration intended for Vector you can supply configuration like so:

```yaml
customConfig:
  #...
  sinks:
    loki:
      #...
      labels:
        foo: bar
        host: |-
          {{ print "{{ host }}" }}
        source: |-
          {{ print "{{ source_type }}" }}
```

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
| affinity | object | `{}` | Allow Vector to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| args | list | `["--config-dir","/etc/vector/"]` | Override Vector's default arguments |
| autoscaling.customMetric | object | `{}` | Target a custom metric |
| autoscaling.enabled | bool | `false` | Enabled autoscaling for the Aggregator and Stateless-Aggregator |
| autoscaling.maxReplicas | int | `10` | Maximum replicas for Vector's HPA |
| autoscaling.minReplicas | int | `1` | Minimum replicas for Vector's HPA |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization for Vector's HPA |
| autoscaling.targetMemoryUtilizationPercentage | int | `nil` | Target memory utilization for Vector's HPA |
| command | list | `[]` | Override Vector's default command |
| commonLabels | object | `{}` | Add additional labels to all created resources |
| containerPorts | list | `[]` | Manually define Vector's Container ports, overrides automated generation of Container ports |
| customConfig | object | `{}` | Override Vector's default configs, if used **all** options need to be specified # This section supports using helm templates to populate dynamic values # Ref: https://vector.dev/docs/reference/configuration/ |
| dataDir | string | `""` | Specify the path for Vector's data, only used when existingConfigMaps are used |
| dnsConfig | object | `{}` | Specify DNS configuration options for Vector Pods # Ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `"ClusterFirst"` | Specify DNS policy for Vector Pods # Ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| env | list | `[]` | Set environment variables in Vector containers # The examples below leverage examples from secrets.generic and assume no name overrides with a Release name of "vector" |
| existingConfigMaps | list | `[]` | List of existing ConfigMaps for Vector's configuration instead of creating a new one, if used requires dataDir to be set. Additionally, containerPorts and service.ports should be specified based on your supplied configuration # If set, this parameter takes precedence over customConfig and the chart's default configs |
| extraVolumeMounts | list | `[]` | Additional Volume to mount into Vector Containers |
| extraVolumes | list | `[]` | Additional Volumes to use with Vector Pods |
| fullnameOverride | string | `""` | Override the full qualified app name |
| image.pullPolicy | string | `"IfNotPresent"` | Vector image pullPolicy |
| image.pullSecrets | list | `[]` | Agent repository pullSecret (ex: specify docker registry credentials) # Ref: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod |
| image.repository | string | `"timberio/vector"` | Override default registry + name for Vector |
| image.sha | string | `""` | Vector image sha to use |
| image.tag | string | Chart's appVersion | Vector image tag to use |
| ingress.annotations | object | `{}` | Set annotations on the Ingress |
| ingress.className | string | `""` | Specify the ingressClassName, requires Kubernetes >= 1.18 # Ref: https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress |
| ingress.enabled | bool | `false` | If true, create and use an Ingress resource |
| ingress.hosts | list | `[]` | Configure the hosts and paths for the Ingress |
| ingress.tls | list | `[]` | Configure TLS for the Ingress |
| initContainers | list | `[]` | Init Containers to be added to the Vector Pod |
| livenessProbe | object | `{}` | Override default liveness probe settings, if customConfig is used requires customConfig.api.enabled true # Requires Vector's API to be enabled |
| nameOverride | string | `""` | Override name of app |
| nodeSelector | object | `{}` | Allow Vector to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Specifies the accessModes for PersistentVolumeClaims # Valid for Aggregator role |
| persistence.enabled | bool | `false` | If true, create and use PersistentVolumeClaims |
| persistence.existingClaim | string | `""` | Name of an existing PersistentVolumeClaim to use # Valid for Aggregator role |
| persistence.finalizers | list | `["kubernetes.io/pvc-protection"]` | Specifies the finalizers of PersistentVolumeClaims # Valid for Aggregator role |
| persistence.hostPath.path | string | `"/var/lib/vector"` | Override path used for hostPath persistence # Valid for Agent role, persistence always used for Agent role |
| persistence.selectors | object | `{}` | Specifies the selectors for PersistentVolumeClaims # Valid for Aggregator role |
| persistence.size | string | `"10Gi"` | Specifies the size of PersistentVolumeClaims # Valid for Aggregator role |
| podAnnotations | object | `{}` | Set annotations on Vector Pods |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget for Vector |
| podDisruptionBudget.maxUnavailable | int | `nil` | The number of Pods that can be unavailable after an eviction |
| podDisruptionBudget.minAvailable | int | `1` | The number of Pods that must still be available after an eviction |
| podLabels | object | `{"vector.dev/exclude":"true"}` | Set labels on Vector Pods |
| podManagementPolicy | string | `"OrderedReady"` | Specify the podManagementPolicy for the Aggregator role # Valid for Aggregator role |
| podMonitor.additionalLabels | object | `{}` | Adds additional labels to the PodMonitor |
| podMonitor.enabled | bool | `false` | If true, create a PodMonitor for Vector |
| podMonitor.honorLabels | bool | `false` | If true, honor_labels is set to true in scrape config # Ref: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config |
| podMonitor.honorTimestamps | bool | `true` | If true, honor_timestamps is set to true in scrape config # Ref: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config |
| podMonitor.jobLabel | string | `"app.kubernetes.io/name"` | Override the label to retrieve the job name from |
| podMonitor.metricRelabelings | list | `[]` | MetricRelabelConfigs to apply to samples before ingestion # Ref: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs |
| podMonitor.path | string | `"/metrics"` | Override the path to scrape |
| podMonitor.port | string | `"prom-exporter"` | Override the port to scrape |
| podMonitor.relabelings | list | `[]` | RelabelConfigs to apply to samples before scraping # Ref: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config |
| podPriorityClassName | string | `""` | Set the priorityClassName on Vector Pods |
| podSecurityContext | object | `{}` | Allows you to overwrite the default PodSecurityContext for Vector |
| psp.create | bool | `false` | If true, create a PodSecurityPolicy resource. PodSecurityPolicy is deprecated as of Kubernetes v1.21, and will be removed in v1.25 # Intended for use with the Agent role |
| rbac.create | bool | `true` | If true, create and use RBAC resources. Only valid for the Agent role |
| readinessProbe | object | `{}` | Override default readiness probe settings, if customConfig is used requires customConfig.api.enabled true # Requires Vector's API to be enabled |
| replicas | int | `1` | Set the number of Pods to create # Valid for Aggregator and Stateless-Aggregator |
| resources | object | `{}` | Set Vector resource requests and limits. |
| role | string | `"Aggregator"` | Role for this Vector (possible values: Agent, Aggregator, Stateless-Aggregator) # Ref: https://vector.dev/docs/setup/deployment/roles/ # Each role is created with the following workloads: # Agent - DaemonSet # Aggregator - StatefulSet # Stateless-Aggregator - Deployment |
| rollWorkload | bool | `true` | Add a checksum of the generated ConfigMap to workload annotations |
| secrets.generic | object | `{}` | Each Key/Value will be added to the Secret's data key, each value should be raw and NOT base64 encoded # Any secrets can be provided here, it's commonly used for credentials and other access related values. # NOTE: Don't commit unencrypted secrets to git! |
| securityContext | object | `{}` | Specify securityContext on Vector containers |
| service.annotations | object | `{}` | Set annotations on Vector's Service |
| service.enabled | bool | `true` | If true, create and use a Service resource |
| service.ports | list | `[]` | Manually set Service ports, overrides automated generation of Service ports |
| service.topologyKeys | list | `[]` | Specify the topologyKeys field on Vector's Service spec # Ref: https://kubernetes.io/docs/concepts/services-networking/service-topology/#using-service-topology |
| service.type | string | `"ClusterIP"` | Set type of Vector's Service |
| serviceAccount.annotations | object | `{}` | Annotations to add to the Vector ServiceAccount |
| serviceAccount.automountToken | bool | `true` | Automount API credentials for the Vector ServiceAccount |
| serviceAccount.create | bool | `true` | If true, create ServiceAccount |
| serviceAccount.name | string | `nil` | The name of the ServiceAccount to use. # If not set and create is true, a name is generated using the fullname template |
| terminationGracePeriodSeconds | int | `60` | Override Vector's terminationGracePeriodSeconds |
| tolerations | list | `[]` | Allow Vector to schedule on tainted nodes |
| updateStrategy | object | `{}` | Customize the updateStrategy used to replace Vector Pods # Also used for the DeploymentStrategy for Stateless-Aggregators # Valid options are used depending on the chosen role # Agent (DaemonSetUpdateStrategy): https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/daemon-set-v1/#DaemonSetSpec) # Aggregator (StatefulSetUpdateStrategy): https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/stateful-set-v1/#StatefulSetSpec # Stateless-Aggregator (DeploymentStrategy): https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/ |

### HAProxy values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| haproxy.affinity | object | `{}` | Allow HAProxy to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| haproxy.autoscaling.customMetric | object | `{}` | Target a custom metric |
| haproxy.autoscaling.enabled | bool | `false` | Enabled autoscaling for HAProxy |
| haproxy.autoscaling.maxReplicas | int | `10` | Maximum replicas for HAProxy's HPA |
| haproxy.autoscaling.minReplicas | int | `1` | Minimum replicas for HAProxy's HPA |
| haproxy.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization for HAProxy's HPA |
| haproxy.autoscaling.targetMemoryUtilizationPercentage | int | `nil` | Target memory utilization for HAProxy's HPA |
| haproxy.containerPorts | list | `[]` | Manually define HAProxy's Container ports, overrides automated generation of Container ports |
| haproxy.customConfig | string | `""` | Override HAProxy's default configs, if used **all** options need to be specified. This parameter supports using Helm templates to insert values dynamically # By default this chart will parse Vector's configuration from customConfig to generate HAProxy's config, this generated config # can be overwritten with haproxy.customConfig |
| haproxy.enabled | bool | `false` | If true, create a HAProxy load balancer |
| haproxy.existingConfigMap | string | `""` | Use this existing ConfigMap for HAProxy's configuration instead of creating a new one. Additionally, haproxy.containerPorts and haproxy.service.ports should be specified based on your supplied configuration # If set, this parameter takes precedence over customConfig and the chart's default configs |
| haproxy.extraVolumeMounts | list | `[]` | Additional Volume to mount into HAProxy Containers |
| haproxy.extraVolumes | list | `[]` | Additional Volumes to use with HAProxy Pods |
| haproxy.image.pullPolicy | string | `"IfNotPresent"` | HAProxy image pullPolicy |
| haproxy.image.pullSecrets | list | `[]` | HAProxy repository pullSecret (ex: specify docker registry credentials) # Ref: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod |
| haproxy.image.repository | string | `"haproxytech/haproxy-alpine"` | Override default registry + name for HAProxy |
| haproxy.image.tag | string | `"2.4.17"` | HAProxy image tag to use |
| haproxy.initContainers | list | `[]` | Init Containers to be added to the HAProxy Pod |
| haproxy.livenessProbe | object | `{"tcpSocket":{"port":1024}}` | Override default HAProxy liveness probe settings |
| haproxy.nodeSelector | object | `{}` | Allow HAProxy to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| haproxy.podAnnotations | object | `{}` | Set annotations on HAProxy Pods |
| haproxy.podLabels | object | `{}` | Set labels on HAProxy Pods |
| haproxy.podPriorityClassName | string | `""` | Set the priorityClassName on HAProxy Pods |
| haproxy.podSecurityContext | object | `{}` | Allows you to overwrite the default PodSecurityContext for HAProxy |
| haproxy.readinessProbe | object | `{"tcpSocket":{"port":1024}}` | Override default HAProxy readiness probe settings |
| haproxy.replicas | int | `1` | Set the number of HAProxy Pods to create |
| haproxy.resources | object | `{}` | Set HAProxy resource requests and limits. |
| haproxy.rollWorkload | bool | `true` | Add a checksum of the generated ConfigMap to the HAProxy Deployment |
| haproxy.securityContext | object | `{}` | Specify securityContext on HAProxy containers |
| haproxy.service.annotations | object | `{}` | Set annotations on HAProxy's Service |
| haproxy.service.ports | list | `[]` | Manually set HAPRoxy's Service ports, overrides automated generation of Service ports |
| haproxy.service.topologyKeys | list | `[]` | Specify the topologyKeys field on HAProxy's Service spec # Ref: https://kubernetes.io/docs/concepts/services-networking/service-topology/#using-service-topology |
| haproxy.service.type | string | `"ClusterIP"` | Set type of HAProxy's Service |
| haproxy.serviceAccount.annotations | object | `{}` | Annotations to add to the HAProxy ServiceAccount |
| haproxy.serviceAccount.automountToken | bool | `true` | Automount API credentials for the HAProxy ServiceAccount |
| haproxy.serviceAccount.create | bool | `true` | If true, create a HAProxy ServiceAccount |
| haproxy.serviceAccount.name | string | `nil` | The name of the HAProxy ServiceAccount to use. # If not set and create is true, a name is generated using the fullname template |
| haproxy.strategy | object | `{}` | Customize the strategy used to replace HAProxy Pods # Ref: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/ |
| haproxy.terminationGracePeriodSeconds | int | `60` | Override HAProxy's terminationGracePeriodSeconds |
| haproxy.tolerations | list | `[]` | Allow HAProxy to schedule on tainted nodes |
