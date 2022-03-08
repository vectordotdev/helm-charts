# Changelog
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [vector-0.7.0-rc.0] - 2022-03-08

### Vector

#### Features

- Add list verb for upcoming kube-rs change ([e390ead](https://github.com/vectordotdev/helm-charts/commit/e390ead62dcc5e2736d9fb7cb1f19ac7684f3d92))

## [vector-0.6.0] - 2022-02-11

### Vector

#### Features

- Update to use 0.20.0 (#164) ([e0f7573](https://github.com/vectordotdev/helm-charts/commit/e0f7573eb84ec2000b4601540076733d93b6148a))

## [vector-0.5.2] - 2022-02-11

## [vector-0.5.1] - 2022-02-09

### Vector

#### Documentation

- Update maintainer email (#161) ([a3dc59a])(https://github.com/vectordotdev/helm-charts/commit/a3dc59aaeaa36bd9f25c527023dbad394e0d3c58)

## [vector-0.5.0] - 2022-02-07

### Vector

#### Bug Fixes

- Include common labels on ClusterRole resource (#144) ([01773ba](https://github.com/vectordotdev/helm-charts/commit/01773baf98257c056f42793bb5f4c136a2926d2a))

#### Documentation

- Fix comment on autoscaling option (#145) ([9d1c3c2](https://github.com/vectordotdev/helm-charts/commit/9d1c3c29575c14b8d2d1a85fe611332d96816d18))
- Fix loki label ends with new line (#154) ([e59c63b](https://github.com/vectordotdev/helm-charts/commit/e59c63be55aa0712aa6b9a35e3c5901d27593770))

#### Features

- Add honorLabels and honorTimestamps to PodMonitor (#153) ([5a92272](https://github.com/vectordotdev/helm-charts/commit/5a9227209d33efc513f5e282d076d8df438205c6))
- Upgrade Vector to 0.19.1 (#157) ([be0dc41](https://github.com/vectordotdev/helm-charts/commit/be0dc411693bd2001b443a1545d9fb810403feeb))

## [vector-0.4.0] - 2022-01-12

### Vector

#### Bug Fixes

- Include common labels on ClusterRole resource (#144) ([01773ba](https://github.com/vectordotdev/helm-charts/commit/01773baf98257c056f42793bb5f4c136a2926d2a))

#### Documentation

- Fix comment on autoscaling option (#145) ([9d1c3c2](https://github.com/vectordotdev/helm-charts/commit/9d1c3c29575c14b8d2d1a85fe611332d96816d18))

## [vector-0.3.0] - 2021-12-28

### Vector

#### Documentation

- Fix example and CI for Vector templating (#126) ([e28ba32](https://github.com/vectordotdev/helm-charts/commit/e28ba3284089d26359d7ea7e87918dc5b9b33257))
- Clarify usage of secrets.generic and env (#129) ([1396dd4](https://github.com/vectordotdev/helm-charts/commit/1396dd42309c8aeded6d20be2a2cc2b9c4e26d1b))

#### Features

- Update charts to Vector 0.19.0 (#131) ([26f9779](https://github.com/vectordotdev/helm-charts/commit/26f9779f49dfc67d76c6b33cfd126f2458a8dc20))

### Vector-aggregator

#### Bug Fixes

- Fix the conditions for enable/disable SA on the HAProxy (#122) ([83cf509](https://github.com/vectordotdev/helm-charts/commit/83cf5091825fbff872819251e00808befc41a331))

## [vector-0.2.2] - 2021-11-30

### Vector

#### Features

- Upgrade Vector to 0.18.1. (#124) ([20f1f0e](https://github.com/vectordotdev/helm-charts/commit/20f1f0e91ac9142d958f112022c9448b62cd46ce))

## [vector-0.2.1] - 2021-11-23

### Vector

#### Bug Fixes

- Switch metric list order in HPA. (#117) ([0a214bb](https://github.com/vectordotdev/helm-charts/commit/0a214bb9f49cf35d4c7d891becdecf84433b9e25))
- Typo podPriorityClassName & StatefulSet (#116) ([31d7eb4](https://github.com/vectordotdev/helm-charts/commit/31d7eb4154fc7ebd81573d6dcbf6de35cd303771))

## [vector-0.2.0] - 2021-11-19

### Vector

#### Features

- Include option to add additionalLabels to PodMonitor (#111) ([0a71e9e](https://github.com/vectordotdev/helm-charts/commit/0a71e9e653431c02ac0273e0b5556fbf1e5e8ded))
- Upgrade Vector to 0.18.0 (#114) ([27b9e98](https://github.com/vectordotdev/helm-charts/commit/27b9e9804a26893a84a46affa69b6f6738ba3b31))

## [vector-0.1.1] - 2021-11-10

### Vector

#### Documentation

- Handle helm-docs processing of vector template example (#107) ([34cb0eb](https://github.com/vectordotdev/helm-charts/commit/34cb0ebeecde276b67ee943a7559543434508930))

## [vector-0.1.0] - 2021-11-09

### Vector

#### Bug Fixes

- Provide default value for only minAvailable in PDB (#98) ([6fcb9de](https://github.com/vectordotdev/helm-charts/commit/6fcb9de045f2c0b0b01bf99082413b7574114ed1))
- Fix type for podDisruptionBudget.maxUnavailable (#104) ([190c2b4](https://github.com/vectordotdev/helm-charts/commit/190c2b437eaea344d037622d8dc5b129e60626d2))
- Toggle both service and headless service with service.enabled (#101) ([a8b7daf](https://github.com/vectordotdev/helm-charts/commit/a8b7dafa4fc6e9bc93ca3669ece7c666a398dc88))

#### Documentation

- Add example customConfig in values.yaml (#102) ([59161b9](https://github.com/vectordotdev/helm-charts/commit/59161b94b1540699c87d18b2eb27a7f8ad4a7adc))
- Add upgrade docs (#75) ([a40bdcc](https://github.com/vectordotdev/helm-charts/commit/a40bdcc5673e7bfe295bcf80690dbc73d6221f43))

## [vector-0.1.0-beta.2] - 2021-11-02

### Vector

#### Bug Fixes

- Upgrade chart to 0.17.3 ([3cf1df5](https://github.com/vectordotdev/helm-charts/commit/3cf1df50ddd16a0db13924c4412fef8d5cc0ffef))
- Fix vector proto in haproxy config (#94) ([b0a7d7d](https://github.com/vectordotdev/helm-charts/commit/b0a7d7d6e430c93376e498ce1653ac9a331d5e60))

#### Documentation

- Document how to use Vector's template syntax in customConfig (#91) ([cf67558](https://github.com/vectordotdev/helm-charts/commit/cf675581854210d128160bd787e9040a96809538))

#### Features

- Add support for user defined initContainers for Vector Pods (#79) ([44a2e5e](https://github.com/vectordotdev/helm-charts/commit/44a2e5ed0877a12a4906947926ea8d576174f006))
- Update secrets.generic to take unencoded values (#84) ([5f66c18](https://github.com/vectordotdev/helm-charts/commit/5f66c1865851894df9d682ffea688f2c95662cf7))
  - **BREAKING**: Update secrets.generic to take unencoded values (#84)
- Ensure good feature parity for HAProxy (#85) ([0cb3798](https://github.com/vectordotdev/helm-charts/commit/0cb379805e464f5dc3ba4180636ba05eefb935ca))
- Update charts to Vector 0.17.2 (#89) ([de3cf26](https://github.com/vectordotdev/helm-charts/commit/de3cf2663eee09360286c15ac8bd85a7f3a0dec2))
- Allow HPA to be used with statefulsets (#92) ([73ae867](https://github.com/vectordotdev/helm-charts/commit/73ae867c31397db64765792a87b2c67c07873919))

## [vector-0.1.0-alpha.4] - 2021-10-01

### Unscoped

#### Documentation

- Clarify suggested usage (#76) ([0555fb0](https://github.com/vectordotdev/helm-charts/commit/0555fb0d339cef1a1815203198102f6e5b0153e7))

### Vector

#### Bug Fixes

- Fix ordering of `default` function in port helpers (#80) ([bc8401f](https://github.com/vectordotdev/helm-charts/commit/bc8401fa449c70845f922c89aa5c6067ffbf23cc))

#### Features

- Add optional PodDisruptionBudget resource for Vector (#57) ([ea65bd0](https://github.com/vectordotdev/helm-charts/commit/ea65bd095cb876b29a747954fdaef28370d87a22))
- Support injecting multiple ConfigMaps (#58) ([337d7d2](https://github.com/vectordotdev/helm-charts/commit/337d7d231ee1d307987fe4945a37bfa6f44c5342))
  - **BREAKING**: Renamed `existingConfigMap` to `existingConfig` and `haproxy.existingConfigMap` to `haproxy.existingConfig`
- Allow option PSP to be created for Agent role (#67) ([a2c535b](https://github.com/vectordotdev/helm-charts/commit/a2c535be68f8fb57ab19e9f852e10312405c6a19))
- Allow for manually setting ports for container and services (#68) ([5901de8](https://github.com/vectordotdev/helm-charts/commit/5901de8e6e68aaff976105f3be59b89f06732c43))
- Create checksum annotations for existingConfig and extraConfigs (#69) ([26a1bd5](https://github.com/vectordotdev/helm-charts/commit/26a1bd52c70dc849ef69ba78f8a60dcde0092f5d))
- Consolidate existing/extraConfig options (#71) ([17c94b8](https://github.com/vectordotdev/helm-charts/commit/17c94b8cbf21e6b1f1dedf329f74f8b928be5d46))
  - **BREAKING**: Renamed existingConfig to existingConfigMaps, renamed haproxy.existingConfig to haproxy.existingConfigMaps removed extraConfigs
- Add parameter to include additional labels on all resources (#73) ([6d1426b](https://github.com/vectordotdev/helm-charts/commit/6d1426b89323d85dd6a9d698aaba550194ce21e4))
- Add extraVolumes and extraVolumeMounts parameters (#74) ([895354f](https://github.com/vectordotdev/helm-charts/commit/895354f4e3ef47a29b36d172187e350add40b535))

## [vector-0.1.0-alpha.3] - 2021-09-17

### Vector

#### Bug Fixes

- Create ports for api from customConfig (#51) ([b82c6b6](https://github.com/vectordotdev/helm-charts/commit/b82c6b62f1f73febbd5ec6ce787e829148f6ef22))

#### Features

- Add override for default Vector command (#49) ([29710f3](https://github.com/vectordotdev/helm-charts/commit/29710f33339f9a9645ffb21e045a391fc13ac335))
- Add support for topologyKeys on all Services (#50) ([47f9e2b](https://github.com/vectordotdev/helm-charts/commit/47f9e2b9ee482d073b99a353fa6d403787a935f6))
- Add optional Ingress resource (#53) ([2b87bf0](https://github.com/vectordotdev/helm-charts/commit/2b87bf01596bb7d4c2583deb4ba8d7a13cb4074f))

<!-- generated by git-cliff -->
