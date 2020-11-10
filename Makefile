DOCKER_COMPOSE = docker-compose -f docker-compose.yml

build:
	docker build -t docker_dhcp ./dhcp-service

push:
	echo ${REGISTRY_URL}
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_dhcp:latest ${REGISTRY_URL}/staff-device-${ENV}-dhcp-docker:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dhcp-docker:latest

publish: build push

deploy:
	./scripts/deploy.sh

build-dev:
	$(DOCKER_COMPOSE) build

start-db:
	$(DOCKER_COMPOSE) up -d db
	./wait_for_db.sh

stop:
	$(DOCKER_COMPOSE) down -v

run: start-db
	$(DOCKER_COMPOSE) up -d dhcp

test-metrics: run build-dev
	./wait_for_dhcp_server.sh
	$(DOCKER_COMPOSE) run --rm dhcp-test rspec ./stats/spec

test: run build-dev
	./wait_for_dhcp_server.sh
	$(DOCKER_COMPOSE) run --rm dhcp-test bash ./dhcp_test.sh

shell: start-db
	$(DOCKER_COMPOSE) run --rm dhcp sh

shell-test: start-db
	$(DOCKER_COMPOSE) run --rm dhcp-test sh

logs:
	$(DOCKER_COMPOSE) logs

implode:
	$(DOCKER_COMPOSE) rm

.PHONY: build publish test shell stop start-db build-dev deploy
