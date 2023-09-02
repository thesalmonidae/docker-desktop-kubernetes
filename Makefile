include make.properties

.DEFAULT_GOAL := help

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n\n", $$1, $$2}'

docker-override-docker-gid: ## Override Docker group ID in the devcontainer.json so it can be used inside the devcontainer by the non-root user.
	sed -i 's/            "DOCKER_GROUP_ID":.*/            "DOCKER_GROUP_ID": "$(shell getent group docker | cut -d: -f3)"/' .devcontainer/devcontainer.json

setup: chart-yaml-generate docker-build docker-push helm-package ## Build Docker image and package Helm chart

chart-yaml-generate: ## Generate Chart.yaml for the app Helm chart
	rm -f ${APP_HELM_CHART_CHART_YAML_PATH} && \
	echo "apiVersion: v2" >> ${APP_HELM_CHART_CHART_YAML_PATH} && \
	echo "name: app" >> ${APP_HELM_CHART_CHART_YAML_PATH} && \
	echo "description: Flask Hello World App" >> ${APP_HELM_CHART_CHART_YAML_PATH} && \
	echo "type: application" >> ${APP_HELM_CHART_CHART_YAML_PATH} && \
	echo "version: ${APP_DOCKER_TAG}" >> ${APP_HELM_CHART_CHART_YAML_PATH} && \
	echo "appVersion: ${APP_HELM_CHART_VERSION}" >> ${APP_HELM_CHART_CHART_YAML_PATH}

docker-build: ## Build app docker image
	DOCKER_BUILDKIT=1 docker build \
		--build-arg PYTHON_TAG=${PYTHON_TAG} \
		--tag ${DOCKER_REGISTRY}/${APP_DOCKER_REPOSITORY}:${APP_DOCKER_TAG} \
		--tag ${DOCKER_REGISTRY}/${APP_DOCKER_REPOSITORY}:latest \
		.

docker-push: ## Push docker image to local registry
	docker push ${DOCKER_REGISTRY}/${APP_DOCKER_REPOSITORY}:${APP_DOCKER_TAG}
	docker push ${DOCKER_REGISTRY}/${APP_DOCKER_REPOSITORY}:${APP_DOCKER_TAG}

docker-run: ## Run app docker image at port 8080
	docker run -it --rm -p 8080:8080 ${DOCKER_REGISTRY}/${APP_DOCKER_REPOSITORY}:latest

helm-package: ## Package app Helm chart
	rm -rf .build && \
	mkdir .build && \
	cd .build && \
	helm package ../helm/app --version ${APP_HELM_CHART_VERSION} --app-version ${APP_DOCKER_TAG}

helm-deploy: ## Deploy app Helm chart into current Kubernetes context in the kubeconfig
	helm install app .build/app-${APP_HELM_CHART_VERSION}.tgz

helm-undeploy: ## Undeploy app Helm chart
	helm uninstall app
