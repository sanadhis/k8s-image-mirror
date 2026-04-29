# k8s-image-mirror

Mirror deployed container images from a source registry to a target registry using Kubernetes as the source of truth. A CronJob runs on a schedule, discovers all images currently running in the cluster, and copies them to the configured target registry using [skopeo](https://github.com/containers/skopeo).

Example use case:
- Re-vendoring of container images from one registry to another.
- Cache container images from K8s data plane to registry cache for failover mechanism and accelerate K8s re-creation.

## Contributing
See [CONTRIBUTING](CONTRIBUTING.MD)
