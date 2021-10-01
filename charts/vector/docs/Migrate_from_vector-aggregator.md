# Migrate from `vector-aggregator` guide

## Vector values

| Old parameter  | New parameter | Comment |
| -------------  | ------------- | ------- |
| `image.version`, `image.base` | ∅ | Only `image.tag` is now used to set the Vector tag |
| `imagePullSecrets` | `image.pullSecrets` | |
| `existingConfigMap` and `extraConfigDirSources` | `existingConfigMaps` | All ConfigMaps in the `existingConfigMaps` list are projected into Vector's configuration directory |
| `extraContainersPorts` | `containerPorts` | Ports will be automatically generated from `customConfig` but can be manually set with `containerPorts` |
| `global.clusterDomain` and `global.kubeDNSAddress` | ∅ | The paramters are set by default or by `haproxy.customConfig` or `haproxy.existingConfigMap` |
| `podMonitor.additionalLabels` | ∅ | |
| `podMonitor.extraRelabelings` | `podMonitor.relabelings` | The chart adds no default relabelings |
| `podRollmeAnnotation` and`podValuesChecksumAnnotation` | ∅ | Replaced by `rollWorkload`, enabled by default |
| `psp.enabled` | `psp.create` | |
| `rbac.enabled` | `rbac.create` | |
| `storage.mode` | ∅ | If `persistence.enabled` a PersistentVolumeClaim will be created, unless `persistence.existingClaim` is set |
| `storage.hostPath` | ∅ | Vector running as an Aggregator no longer supports `hostPath` based storage |
| `storage.managedPersistentVolumeClaim.size` | `persistence.size` | |
| `storage.managedPersistentVolumeClaim.storageClass` | `persistence.storageClassName` | |
| `storage.existingPersistentVolumeClaim` | `persistence.existingClaim` | |

## HAProxy values

| Old parameter  | New parameter | Comment |
| -------------  | ------------- | ------- |
