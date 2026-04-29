CHART_DIR   := chart
DOCKER_DIR  := docker
IMAGE_NAME  := k8s-image-mirror
IMAGE_TAG   := local

.PHONY: lint unittest schema test docker-build docker-build-test

setup:
	pre-commit install
	pre-commit install --hook-type commit-msg

plugins:
	helm plugin install https://github.com/helm-unittest/helm-unittest.git
	helm plugin install https://github.com/losisin/helm-values-schema-json.git

lint:
	helm lint $(CHART_DIR)

unittest:
	helm unittest $(CHART_DIR)

schema:
	helm schema -f $(CHART_DIR)/values.yaml -o $(CHART_DIR)/values.schema.json --use-helm-docs

helm-test: lint unittest

package:
	helm package $(CHART_DIR) --version $(IMAGE_TAG)

helm-login:
	helm registry login -u $(USERNAME) -p $(PASSWORD) $(HELM_REGISTRY)

publish:
	helm push ./k8s-image-mirror-$(IMAGE_TAG).tgz $(HELM_REGISTRY)

docker-build:
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		$(DOCKER_DIR)

docker-build-test:
	docker run --pull missing --entrypoint kubectl \
		-t $(IMAGE_NAME):$(IMAGE_TAG) version --client
	docker run --pull missing --entrypoint skopeo \
		-t $(IMAGE_NAME):$(IMAGE_TAG) -v
