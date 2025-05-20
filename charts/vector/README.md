# Vector

![Version: 0.43.0](https://img.shields.io/badge/Version-0.43.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.47.0-distroless-libc](https://img.shields.io/badge/AppVersion-0.47.0--distroless--libc-informational?style=flat-square)

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
helm install <RELEASE_NAME> vector/vector
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
2. Upgrade the Vector chart with your new `values.yaml` file:

```bash
helm upgrade -f values.yaml <RELEASE_NAME> vector/vector
```

**Vector recommends that your `values.yaml` only contain values that need to be overridden, as it allows a smoother experience when upgrading chart versions.**

See the [configuration options](#all-configuration-options) section to discover all possibilities offered by the Vector chart.

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
helm install <RELEASE_NAME> \
  vector/vector \
  --set role=Agent
```

## Values

### Vector values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Configure [affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) rules for Vector Pods. |
| args | list | `["--config-dir","/etc/vector/"]` | Override Vector's default arguments. |
| autoscaling.annotations | object | `{}` | Annotations to add to Vector's HPA. |
| autoscaling.behavior | object | `{}` | Configure separate scale-up and scale-down behaviors. |
| autoscaling.customMetric | object | `{}` | Target a custom metric for autoscaling. |
| autoscaling.enabled | bool | `false` | Create a [HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) for Vector. Valid for the "Aggregator" and "Stateless-Aggregator" roles. |
| autoscaling.external | bool | `false` | Set to `true` if using an external autoscaler like [KEDA](https://keda.sh/). Valid for the "Aggregator and "Stateless-Aggregator" roles. |
| autoscaling.maxReplicas | int | `10` | Maximum replicas for Vector's HPA. |
| autoscaling.minReplicas | int | `1` | Minimum replicas for Vector's HPA. |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization for Vector's HPA. |
| autoscaling.targetMemoryUtilizationPercentage | int | `nil` | Target memory utilization for Vector's HPA. |
| command | list | `[]` | Override Vector's default command. |
| commonLabels | object | `{}` | Add additional labels to all created resources. |
| containerPorts | list | `[]` | Manually define Vector's containerPorts, overriding automated generation of containerPorts. |
| customConfig | object | `{}` | Override Vector's default configs, if used **all** options need to be specified. This section supports using helm templates to populate dynamic values. See Vector's [configuration documentation](https://vector.dev/docs/reference/configuration/) for all options. |
| dataDir | string | `""` | Specify the path for Vector's data, only used when existingConfigMaps are used. |
| defaultVolumeMounts | list | See `values.yaml` | Default volume mounts. Corresponds to `volumes`. |
| defaultVolumes | list | See `values.yaml` | Default volumes that are mounted into pods. In most cases, these should not be changed. Use `extraVolumes`/`extraVolumeMounts` for additional custom volumes. |
| dnsConfig | object | `{}` | Specify the [dnsConfig](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config) options for Vector Pods. |
| dnsPolicy | string | `"ClusterFirst"` | Specify the [dnsPolicy](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy) for Vector Pods. |
| env | list | `[]` | Set environment variables for Vector containers. |
| envFrom | list | `[]` | Define environment variables from Secrets or ConfigMaps. |
| existingConfigMaps | list | `[]` | List of existing ConfigMaps for Vector's configuration instead of creating a new one. Requires dataDir to be set. Additionally, containerPorts, service.ports, and serviceHeadless.ports should be specified based on your supplied configuration. If set, this parameter takes precedence over customConfig and the chart's default configs. |
| extraContainers | list | `[]` | Extra Containers to be added to the Vector Pods. This also supports template content, which will eventually be converted to yaml. |
| extraObjects | list | `[]` | Create extra manifests via values. Would be passed through `tpl` for templating. |
| extraVolumeMounts | list | `[]` | Additional Volume to mount into Vector Containers. |
| extraVolumes | list | `[]` | Additional Volumes to use with Vector Pods. |
| fullnameOverride | string | `""` | Override the full name of resources. |
| hostAliases | list | `[]` |  |
| image.base | string | `""` | The base distribution to use for vector. If set, then the base in appVersion will be replaced with this base alongside the version. For example: with a `base` of `debian` `0.38.0-distroless-libc` becomes `0.38.0-debian` |
| image.pullPolicy | string | `"IfNotPresent"` | The [pullPolicy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy) for Vector's image. |
| image.pullSecrets | list | `[]` | The [imagePullSecrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod) to reference for the Vector Pods. |
| image.repository | string | `"timberio/vector"` | Override default registry and name for Vector's image. |
| image.sha | string | `""` | The SHA to use for Vector's image. |
| image.tag | string | Derived from the Chart's appVersion. | The tag to use for Vector's image. |
| ingress.annotations | object | `{}` | Set annotations on the Ingress. |
| ingress.className | string | `""` | Specify the [ingressClassName](https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress), requires Kubernetes >= 1.18 |
| ingress.enabled | bool | `false` | If true, create and use an Ingress resource. |
| ingress.hosts | list | `[]` | Configure the hosts and paths for the Ingress. |
| ingress.tls | list | `[]` | Configure TLS for the Ingress. |
| initContainers | list | `[]` | Init Containers to be added to the Vector Pods. This also supports template content, which will eventually be converted to yaml. |
| lifecycle | object | `{}` | Set lifecycle hooks for Vector containers. |
| livenessProbe | object | `{}` | Override default liveness probe settings. If customConfig is used, requires customConfig.api.enabled to be set to true. |
| logLevel | string | `"info"` |  |
| minReadySeconds | int | `0` | Specify the minimum number of seconds a newly spun up pod should wait to pass healthchecks before it is considered available. |
| nameOverride | string | `""` | Override the name of resources. |
| nodeSelector | object | `{}` | Configure a [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) for Vector Pods. |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Specifies the accessModes for PersistentVolumeClaims. Valid for the "Aggregator" role. |
| persistence.enabled | bool | `false` | If true, create and use PersistentVolumeClaims. |
| persistence.existingClaim | string | `""` | Name of an existing PersistentVolumeClaim to use. Valid for the "Aggregator" role. |
| persistence.finalizers | list | `["kubernetes.io/pvc-protection"]` | Specifies the finalizers of PersistentVolumeClaims. Valid for the "Aggregator" role. |
| persistence.hostPath.enabled | bool | `true` | If true, use hostPath persistence. Valid for the "Agent" role, if it's disabled the "Agent" role will use emptyDir. |
| persistence.hostPath.path | string | `"/var/lib/vector"` | Override path used for hostPath persistence. Valid for the "Agent" role, persistence is always used for the "Agent" role. |
| persistence.retentionPolicy | object | `{}` | Configure a [PersistentVolumeClaimRetentionPolicy](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#persistentvolumeclaim-retention) for Vector's PersistentVolumeClaims. Valid for the "Aggregator" role. |
| persistence.selectors | object | `{}` | Specifies the selectors for PersistentVolumeClaims. Valid for the "Aggregator" role. |
| persistence.size | string | `"10Gi"` | Specifies the size of PersistentVolumeClaims. Valid for the "Aggregator" role. |
| podAnnotations | object | `{}` | Set annotations on Vector Pods. |
| podDisruptionBudget.enabled | bool | `false` | Enable a [PodDisruptionBudget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) for Vector. |
| podDisruptionBudget.maxUnavailable | int | `nil` | The number of Pods that can be unavailable after an eviction. |
| podDisruptionBudget.minAvailable | int | `1` | The number of Pods that must still be available after an eviction. |
| podHostNetwork | bool | `false` | Configure hostNetwork on Vector Pods. |
| podLabels | object | `{"vector.dev/exclude":"true"}` | Set labels on Vector Pods. |
| podManagementPolicy | string | `"OrderedReady"` | Specify the [podManagementPolicy](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-management-policies) for the StatefulSet. Valid for the "Aggregator" role. |
| podMonitor.additionalLabels | object | `{}` | Adds additional labels to the PodMonitor. |
| podMonitor.enabled | bool | `false` | If true, create a PodMonitor for Vector. |
| podMonitor.honorLabels | bool | `false` | If true, honor_labels is set to true in the [scrape config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config). |
| podMonitor.honorTimestamps | bool | `true` | If true, honor_timestamps is set to true in the [scrape config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config). |
| podMonitor.interval | string | `nil` | Override the interval at which metrics should be scraped. |
| podMonitor.jobLabel | string | `"app.kubernetes.io/name"` | Override the label to retrieve the job name from. |
| podMonitor.metricRelabelings | list | `[]` | [MetricRelabelConfigs](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs) to apply to samples before ingestion. |
| podMonitor.path | string | `"/metrics"` | Override the path to scrape. |
| podMonitor.podTargetLabels | list | `[]` | [podTargetLabels](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.PodMonitorSpec) transfers labels on the Kubernetes Pod onto the target. |
| podMonitor.port | string | `"prom-exporter"` | Override the port to scrape. |
| podMonitor.relabelings | list | `[]` | [RelabelConfigs](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config) to apply to samples before scraping. |
| podMonitor.scrapeTimeout | string | `nil` | Override the timeout after which the scrape is ended. |
| podPriorityClassName | string | `""` | Set the [priorityClassName](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass) on Vector Pods. |
| podSecurityContext | object | `{}` | Allows you to overwrite the default [PodSecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for Vector Pods. |
| psp.create | bool | `false` | If true, create a [PodSecurityPolicy](https://kubernetes.io/docs/concepts/security/pod-security-policy/) resource. PodSecurityPolicy is deprecated as of Kubernetes v1.21, and will be removed in v1.25. Intended for use with the "Agent" role. |
| rbac.create | bool | `true` | If true, create and use RBAC resources. Only valid for the "Agent" role. |
| readinessProbe | object | `{}` | Override default readiness probe settings. If customConfig is used, requires customConfig.api.enabled to be set to true. |
| replicas | int | `1` | Specify the number of Pods to create. Valid for the "Aggregator" and "Stateless-Aggregator" roles. |
| resources | object | `{}` | Set Vector resource requests and limits. |
| role | string | `"Aggregator"` | [Role](https://vector.dev/docs/setup/deployment/roles/) for this Vector instance, valid options are: "Agent", "Aggregator", and "Stateless-Aggregator". |
| rollWorkload | bool | `true` | Add a checksum of the generated ConfigMap to workload annotations. |
| rollWorkloadExtraObjects | bool | `false` | Add a checksum of the generated ExtraObjects to workload annotations. |
| rollWorkloadSecrets | bool | `false` | Add a checksum of the generated Secret to workload annotations. |
| secrets.generic | object | `{}` | Each Key/Value will be added to the Secret's data key, each value should be raw and NOT base64 encoded. Any secrets can be provided here. It's commonly used for credentials and other access related values. **NOTE: Don't commit unencrypted secrets to git!** |
| securityContext | object | `{}` | Specify securityContext on Vector containers. |
| service.annotations | object | `{}` | Set annotations on Vector's Service. |
| service.enabled | bool | `true` | If true, create and provide a Service resource for Vector. |
| service.externalTrafficPolicy | string | `""` | Specify the [externalTrafficPolicy](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip). |
| service.internalTrafficPolicy | string | `""` | Specify the [internalTrafficPolicy](https://kubernetes.io/docs/concepts/services-networking/service-traffic-policy). |
| service.ipFamilies | list | `[]` | Configure [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). |
| service.ipFamilyPolicy | string | `""` | Configure [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). |
| service.loadBalancerIP | string | `""` | Specify the [loadBalancerIP](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer). |
| service.ports | list | `[]` | Manually set the Service ports, overriding automated generation of Service ports. |
| service.topologyKeys | list | `[]` | Specify the [topologyKeys](https://kubernetes.io/docs/concepts/services-networking/service-topology/#using-service-topology) field on Vector's Service. |
| service.type | string | `"ClusterIP"` | Set the type for Vector's Service. |
| serviceAccount.annotations | object | `{}` | Annotations to add to Vector's ServiceAccount. |
| serviceAccount.automountToken | bool | `true` | Automount API credentials for Vector's ServiceAccount. |
| serviceAccount.create | bool | `true` | If true, create a ServiceAccount for Vector. |
| serviceAccount.name | string | `nil` | The name of the ServiceAccount to use. If not set and serviceAccount.create is true, a name is generated using the fullname template. |
| serviceHeadless.enabled | bool | `true` | If true, create and provide a Headless Service resource for Vector. |
| shareProcessNamespace | bool | `false` | Specify the [shareProcessNamespace](https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/) options for Vector Pods. |
| terminationGracePeriodSeconds | int | `60` | Override Vector's terminationGracePeriodSeconds. |
| tolerations | list | `[]` | Configure Vector Pods to be scheduled on [tainted](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) nodes. |
| topologySpreadConstraints | list | `[]` | Configure [topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) for Vector Pods. Valid for the "Aggregator" and "Stateless-Aggregator" roles. |
| updateStrategy | object | `{}` | Customize the updateStrategy used to replace Vector Pods, this is also used for the DeploymentStrategy for the "Stateless-Aggregators". Valid options depend on the chosen role. |
| workloadResourceAnnotations | object | `{}` | Set annotations on the Vector DaemonSet, Deployment or StatefulSet. |

### HAProxy values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| haproxy.affinity | object | `{}` | Configure [affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) rules for HAProxy Pods. |
| haproxy.autoscaling.customMetric | object | `{}` | Target a custom metric for autoscaling. |
| haproxy.autoscaling.enabled | bool | `false` | Create a HorizontalPodAutoscaler for HAProxy. |
| haproxy.autoscaling.external | bool | `false` | HAProxy is controlled by an external HorizontalPodAutoscaler. |
| haproxy.autoscaling.maxReplicas | int | `10` | Maximum replicas for HAProxy's HPA. |
| haproxy.autoscaling.minReplicas | int | `1` | Minimum replicas for HAProxy's HPA. |
| haproxy.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization for HAProxy's HPA. |
| haproxy.autoscaling.targetMemoryUtilizationPercentage | int | `nil` | Target memory utilization for HAProxy's HPA. |
| haproxy.containerPorts | list | `[]` | Manually define HAProxy's containerPorts, overrides automated generation of containerPorts. |
| haproxy.customConfig | string | `""` | Override HAProxy's default configs, if used **all** options need to be specified. This parameter supports using Helm templates to insert values dynamically. By default, this chart will parse Vector's configuration from customConfig to generate HAProxy's config, which can be overwritten with haproxy.customConfig. |
| haproxy.enabled | bool | `false` | If true, create a HAProxy load balancer. |
| haproxy.existingConfigMap | string | `""` | Use this existing ConfigMap for HAProxy's configuration instead of creating a new one. Additionally, haproxy.containerPorts and haproxy.service.ports should be specified based on your supplied configuration. If set, this parameter takes precedence over customConfig and the chart's default configs. |
| haproxy.extraContainers | list | `[]` | Extra Containers to be added to the HAProxy Pods. This also supports template content, which will eventually be converted to yaml. |
| haproxy.extraVolumeMounts | list | `[]` | Additional Volume to mount into HAProxy Containers. |
| haproxy.extraVolumes | list | `[]` | Additional Volumes to use with HAProxy Pods. |
| haproxy.image.pullPolicy | string | `"IfNotPresent"` | HAProxy image pullPolicy. |
| haproxy.image.pullSecrets | list | `[]` | The [imagePullSecrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod) to reference for the HAProxy Pods. |
| haproxy.image.repository | string | `"haproxytech/haproxy-alpine"` | Override default registry and name for HAProxy. |
| haproxy.image.tag | string | `"2.6.12"` | The tag to use for HAProxy's image. |
| haproxy.initContainers | list | `[]` | Init Containers to be added to the HAProxy Pods. This also supports template content, which will eventually be converted to yaml. |
| haproxy.livenessProbe | object | `{"tcpSocket":{"port":1024}}` | Override default HAProxy liveness probe settings. |
| haproxy.nodeSelector | object | `{}` | Configure a [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) for HAProxy Pods |
| haproxy.podAnnotations | object | `{}` | Set annotations on HAProxy Pods. |
| haproxy.podLabels | object | `{}` | Set labels on HAProxy Pods. |
| haproxy.podPriorityClassName | string | `""` | Set the priorityClassName on HAProxy Pods. |
| haproxy.podSecurityContext | object | `{}` | Allows you to overwrite the default PodSecurityContext for HAProxy. |
| haproxy.readinessProbe | object | `{"tcpSocket":{"port":1024}}` | Override default HAProxy readiness probe settings. |
| haproxy.replicas | int | `1` | Set the number of HAProxy Pods to create. |
| haproxy.resources | object | `{}` | Set HAProxy resource requests and limits. |
| haproxy.rollWorkload | bool | `true` | Add a checksum of the generated ConfigMap to the HAProxy Deployment. |
| haproxy.securityContext | object | `{}` | Specify securityContext on HAProxy containers. |
| haproxy.service.annotations | object | `{}` | Set annotations on HAProxy's Service. |
| haproxy.service.externalTrafficPolicy | string | `""` | Specify the [externalTrafficPolicy](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip). |
| haproxy.service.ipFamilies | list | `[]` | Configure [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). |
| haproxy.service.ipFamilyPolicy | string | `""` | Configure [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). |
| haproxy.service.loadBalancerIP | string | `""` | Specify the [loadBalancerIP](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer). |
| haproxy.service.ports | list | `[]` | Manually set HAPRoxy's Service ports, overrides automated generation of Service ports. |
| haproxy.service.topologyKeys | list | `[]` | Specify the [topologyKeys](https://kubernetes.io/docs/concepts/services-networking/service-topology/#using-service-topology) field on HAProxy's Service spec. |
| haproxy.service.type | string | `"ClusterIP"` | Set type of HAProxy's Service. |
| haproxy.serviceAccount.annotations | object | `{}` | Annotations to add to the HAProxy ServiceAccount. |
| haproxy.serviceAccount.automountToken | bool | `true` | Automount API credentials for the HAProxy ServiceAccount. |
| haproxy.serviceAccount.create | bool | `true` | If true, create a HAProxy ServiceAccount. |
| haproxy.serviceAccount.name | string | `nil` | The name of the HAProxy ServiceAccount to use. If not set and create is true, a name is generated using the fullname template. |
| haproxy.strategy | object | `{}` | Customize the [strategy](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/) used to replace HAProxy Pods. |
| haproxy.terminationGracePeriodSeconds | int | `60` | Override HAProxy's terminationGracePeriodSeconds. |
| haproxy.tolerations | list | `[]` | Configure HAProxy Pods to be scheduled on [tainted](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) nodes. |
