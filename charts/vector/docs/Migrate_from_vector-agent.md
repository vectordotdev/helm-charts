# Migrate from `vector-agent` guide

## Vector values

| Old parameter | New parameter | Comment |
| ------------- | ------------- | ------- |
| `dataVolume.hostPath.path` | `persistence.hostPath.path` | |
| `image.version`, `image.base` | ∅ | Only `image.tag` is now used to set the Vector tag |
| `imagePullSecrets` | `image.pullSecrets` | |
| `existingConfigMap` and `extraConfigDirSources` | `existingConfigMaps` | All ConfigMaps in the `existingConfigMaps` list are projected into Vector's configuration directory |
| `extraContainersPorts` | `containerPorts` | Ports will be automatically generated from `customConfig` but can be manually set with `containerPorts` |
| `maxUnavailable` | ∅ | `maxUnavailable` should be passed in as part of the `updateStrategy` object |
| `podMonitor.additionalLabels` | ∅ | |
| `podMonitor.extraRelabelings` | `podMonitor.relabelings` | The chart adds no default relabelings |
| `podRollmeAnnotation` and`podValuesChecksumAnnotation` | ∅ | Replaced by `rollWorkload`, enabled by default |
| `psp.enabled` | `psp.create` | |
| `rbac.enabled` | `rbac.create` | |
| `secrets.generic` | ⚠️ | `secrets.generic` now takes raw values rather than base64 encoded values |
| `updateStrategy` | ⚠️ | `updateStrategy` now takes an object instead of a string |
