# Vector Aggregator Changelog

## 0.17.1

* Remove labels on PersistentVolumeClaim that may change with upgrades
  * NOTE: This bug blocks upgrades and requires the chart to be installed from scratch

## 0.17.0

* Port `args`, `livenessProbe`, `readinessProbe`, `dnsPolicy`, `dnsConfig`, and `secrets` from original charts
* Add `service.annotations` support (non-headless service)
* Remove default tolerations allowing pods to be scheduled on `node-role.kubernetes.io/master` nodes
