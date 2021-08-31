# Vector Aggregator Changelog

## 0.17.0

* Port `args`, `livenessProbe`, `readinessProbe`, `dnsPolicy`, `dnsConfig`, and `secrets` from original charts
* Add `service.annotations` support (non-headless service)
* Remove default tolerations allowing pods to be scheduled on `node-role.kubernetes.io/master` nodes
