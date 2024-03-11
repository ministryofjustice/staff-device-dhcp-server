-include .env
export

.DEFAULT_GOAL := help

DOCKER_COMPOSE = docker-compose -f docker-compose.yml

.PHONY: authenticate-docker
authenticate-docker: ## Authenticate docker using ssm paramstore
	./scripts/authenticate_docker.sh

.PHONY: build
build: ## Docker build dhcp service
	docker build --platform=linux/amd64 -t dhcp ./dhcp-service

.PHONY: build-nginx
build-nginx: ## Docker build nginx
	docker build --platform=linux/amd64 -t nginx ./nginx

.PHONY: push-nginx
push-nginx: ## Docker tag nginx with latest and push to ECR
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag nginx:latest ${REGISTRY_URL}/staff-device-${ENV}-dhcp-nginx:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dhcp-nginx:latest

.PHONY: push
push: ## Docker tag dhcp image with latest and push to ECR
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag dhcp:latest ${REGISTRY_URL}/staff-device-${ENV}-dhcp:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dhcp:latest

.PHONY: publish
publish: ## Build docker image, tag and push  dhcp:latest, build nginx image, tag with latest and push
	$(MAKE) build
	$(MAKE) push
	$(MAKE) build-nginx
	$(MAKE) push-nginx

.PHONY: deploy
deploy: ## Run deploy script
	./scripts/deploy.sh

.PHONY: build-dev
build-dev: ## Build dev image
	$(DOCKER_COMPOSE) build

.PHONY: start-db
start-db: ## start database
	$(DOCKER_COMPOSE) up -d db
	./scripts/wait_for_db.sh

.PHONY: stop
stop: ## Stop and remove containers
	$(DOCKER_COMPOSE) down -v

.PHONY: run
run: ## Build dev image and start dhcp container
	$(MAKE) start-db
	$(DOCKER_COMPOSE) up -d dhcp-primary
	./scripts/wait_for_dhcp_server.sh
	$(DOCKER_COMPOSE) up -d dhcp-standby
	$(DOCKER_COMPOSE) up -d dhcp-api

.PHONY: test
test: ## Build dev container, start dhcp container, run tests
	$(MAKE) run
	$(MAKE) build-dev
	./scripts/wait_for_dhcp_server.sh
	$(DOCKER_COMPOSE) run --rm dhcp-test rspec -f d ./spec

.PHONY: shell
shell: ## Build dev image and start dhcp in shell
	$(MAKE) start-db
	$(DOCKER_COMPOSE) run --rm dhcp-primary sh

.PHONY: shell-test
shell-test: ## Build dev container and tests in shell
	$(MAKE) start-db
	$(DOCKER_COMPOSE) run --rm dhcp-test sh

.PHONY: logs
logs: ## Command will continue streaming the new output from the container's stdout and stderr
	$(DOCKER_COMPOSE) logs --follow

.PHONY: implode
implode: ## remove docker container
	$(DOCKER_COMPOSE) rm

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
