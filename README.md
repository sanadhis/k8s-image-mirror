# k8s-image-mirror

Mirror deployed container images from a source registry to a target registry using Kubernetes as the source of truth. A CronJob runs on a schedule, discovers all images currently running in the cluster, and copies them to the configured target registry using [skopeo](https://github.com/containers/skopeo).

Example use case:
- Re-vendoring of container images from one registry to another.
- Cache container images from K8s data plane to registry cache for failover mechanism and accelerate K8s re-creation.

## Development

### Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) with the following plugins:
  - [`helm unittest`](https://github.com/helm-unittest/helm-unittest) — `helm plugin install https://github.com/helm-unittest/helm-unittest`
  - [`helm schema`](https://github.com/losisin/helm-values-schema-json) — `helm plugin install https://github.com/losisin/helm-values-schema-json`
- [pre-commit](https://pre-commit.com/#install)
- [Docker](https://docs.docker.com/get-docker/)

### Setup

Run once after cloning to install all pre-commit hooks and Helm plugins:

```bash
make setup
make plugins
```

This installs both the `pre-commit` and `commit-msg` hook types, and the required `helm unittest` and `helm schema` plugins.

### Makefile targets

#### Development

| Target                   | Description                                                            |
|--------------------------|------------------------------------------------------------------------|
| `make setup`             | Install pre-commit hooks                                               |
| `make plugins`           | Install Helm plugins                                                   |
| `make lint`              | Lint the Helm chart with `helm lint`                                   |
| `make unittest`          | Run Helm unit tests with `helm unittest`                               |
| `make schema`            | Verify `values.schema.json` is in sync with `values.yaml`              |
| `make test`              | Run `lint`, `unittest`, and `schema` in sequence                       |
| `make helm-test`         | Run `lint` and `unittest` (used in CI)                                 |
| `make docker-build`      | Build the mirror Docker image tagged `k8s-image-mirror:local`          |
| `make docker-build-test` | Smoke-test the built image by checking `kubectl` and `skopeo` versions |

#### Release Helm chart

| Target                                                      | Description                                 |
|-------------------------------------------------------------|---------------------------------------------|
| `make package IMAGE_TAG=<version>`                          | Package the Helm chart as a `.tgz`          |
| `make helm-login HELM_REGISTRY=<registry>`                  | Log in to an OCI Helm registry              |
| `make publish IMAGE_TAG=<version> HELM_REGISTRY=<registry>` | Push the packaged chart to the OCI registry |

### Pre-commit hooks

On every `git commit` the following checks run automatically:

| Hook                       | Stage        | Scope                          |
|----------------------------|--------------|--------------------------------|
| `check-json`               | `pre-commit` | All JSON files                 |
| `end-of-file-fixer`        | `pre-commit` | All files                      |
| `trailing-whitespace`      | `pre-commit` | All files                      |
| `helm-lint`                | `pre-commit` | Changes under `chart/`         |
| `helm-unittest`            | `pre-commit` | Changes under `chart/`         |
| `helm-schema`              | `pre-commit` | Changes to `chart/values.yaml` |
| `conventional-pre-commit`  | `commit-msg` | Commit message                 |

Commit messages must follow the [Angular commit convention](https://www.conventionalcommits.org):

```
<type>(<scope>): <subject>

# Examples
feat(chart): add resource limits
fix(mirror): handle empty image list
chore: update dependencies
```

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`, `revert`.

To run all hooks manually against every file:

```bash
pre-commit run --all-files
```

## Docker image

The mirror job runs as the `docker/` image. It is based on Alpine and contains:

- [`skopeo`](https://github.com/containers/skopeo) — copies images between registries
- [`kubectl`](https://kubernetes.io/docs/reference/kubectl/) — queries the cluster for running images
- `bash` — required by `mirror.sh`

The image runs as a non-root user (`uid 1000`) with `mirror.sh` as the entrypoint.

### Build

```bash
make docker-build
```

### Smoke test

```bash
make docker-build-test
```

## CI/CD

| Workflow            | Trigger                                           | What it does                                                       |
|---------------------|---------------------------------------------------|--------------------------------------------------------------------|
| **Chart PR**        | PR touching `chart/**`                            | Runs `helm lint` and `helm unittest`                               |
| **Docker PR**       | PR touching `docker/**`                           | Builds multi-platform image, pushes `:pr-test` tag, smoke-tests it |
| **Trigger Release** | Push to `main` touching `chart/**` or `docker/**` | Opens a release PR via release-please                              |
| **Release**         | Push to `main` touching `CHANGELOG.md`            | Builds and pushes Docker image + Helm chart to `ghcr.io`           |
