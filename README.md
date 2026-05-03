# k8s-image-mirror

Mirror deployed container images from a source registry to a target registry using Kubernetes as the source of truth. A CronJob runs on a schedule, discovers all images currently running in the cluster, and copies them to the configured target registry using [skopeo](https://github.com/containers/skopeo).

Example use case:
- Re-vendoring of container images from one registry to another.
- Cache container images from K8s data plane to registry cache for failover mechanism and accelerate K8s re-creation.

## Installing the Chart

To install the chart with the release name `k8s-image-mirror`:

```console
helm repo add sanadhis-github oci://ghcr.io/sanadhis/charts
helm install \
  k8s-image-mirror sanadhis-github/k8s-image-mirror \
  --namespace k8s-image-mirror \
  --create-namespace \
  --version {{RELEASE_VERSION}} \
  --set targetRegistry=quay.io/someneworg \
  --set sourceFilter=gcr.io/someorg \
  --set credentials.targetRegistryUsername={{target-registry-username}} \
  --set credentials.targetRegistryPassword={{target-registry-password}} \
  --set credentials.sourceRegistryUsername={{source-registry-username}} \
  --set credentials.sourceRegistryPassword={{source-registry-password}}
```

### Configuration

| Value                                      | Description                                          | Default       | Required |
|--------------------------------------------|------------------------------------------------------|---------------|----------|
| `targetRegistry`                           | Target registry to mirror images to                  | `""`          | Yes      |
| `sourceFilter`                             | Regex to filter source images by registry/namespace  | `".*"`        | No       |
| `job.schedule`                             | Cron schedule for the mirror job                     | `"0 2 * * *"` | No       |
| `stripNamespace`                           | Strip the namespace prefix from mirrored image names | `false`       | No       |
| `srcTlsVerify`                             | Verify TLS for the source registry                   | `true`        | No       |
| `destTlsVerify`                            | Verify TLS for the target registry                   | `true`        | No       |
| `credentials.targetRegistryUsername`       | Plain-text username for the target registry          | `""`          | No       |
| `credentials.targetRegistryPassword`       | Plain-text password for the target registry          | `""`          | No       |
| `credentials.existingTargetRegistrySecret` | Existing Secret name for target registry credentials | `""`          | No       |
| `credentials.sourceRegistryUsername`       | Plain-text username for the source registry          | `""`          | No       |
| `credentials.sourceRegistryPassword`       | Plain-text password for the source registry          | `""`          | No       |
| `credentials.existingSourceRegistrySecret` | Existing Secret name for source registry credentials | `""`          | No       |

## Contributing
See [CONTRIBUTING](CONTRIBUTING.MD)
