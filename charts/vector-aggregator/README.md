# [Vector](https://vector.dev) Helm Chart

**DEPRECATED** This chart has been deprecated for the [`vector` chart](../vector).

This is an opinionated Helm Chart for running [Vector](https://vector.dev) as an [aggregator](https://vector.dev/docs/about/concepts/#aggregator) in Kubernetes.

To get started check out our [documentation](https://vector.dev/docs/setup/installation/platforms/kubernetes/)

## Load Balancing (Beta)

As of the 0.15.0 release we've included a HAProxy deployment to load balance traffic to Vector instances running in the [aggregator](https://vector.dev/docs/setup/deployment/roles/#aggregator) role.
Using an external proxy allows us to scale aggregators horizontally in a `source` agnostic way, making it easy to migrate existing infrastructure to use Vector.

To enable the HAProxy deployment you can pass `--set haproxy.enabled=true` with your `helm` command[^1], by default this will create `frontend` and [server-template](http://cbonte.github.io/haproxy-dconv/2.4/configuration.html#4-server-template) configurations generated from your `service.ports` entries. Assuming a release name of "vector" clients sending events to an aggregator with HAProxy enabled should the hostname of "vector-aggregator-haproxy".
With HAProxy we leverage its builtin [resolvers](http://cbonte.github.io/haproxy-dconv/2.4/configuration.html#5.3.2) configuration and Kubernetes DNS to dynamically populate the backend Vector instances.

Our default configurations are designed to work out of the box, but we recommend production deployments should optimize their configuration based on the specific needs of that environment and configuration.

[^1]: Or set it in your values file with:

```yaml
haproxy:
  enabled: true
```
