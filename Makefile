DOCKER_COMPOSE = docker-compose -f docker-compose.yml

build:
	docker build -t docker_dhcp ./dhcp-service

deploy: build
	echo ${REGISTRY_URL}
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_dhcp:latest ${REGISTRY_URL}/staff-device-${ENV}-dhcp-docker-dhcp:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dhcp-docker-dhcp:latest

build-dev:
	$(DOCKER_COMPOSE) build

start-db:
	$(DOCKER_COMPOSE) up -d db
	./wait_for_db.sh

stop:
	$(DOCKER_COMPOSE) down -v

run: start-db
	$(DOCKER_COMPOSE) up -d dhcp

test: run
	$(DOCKER_COMPOSE) run --rm dhcp-test bash ./dhcp_test.sh

shell: start-db
	$(DOCKER_COMPOSE) run --rm dhcp-test bash  

.PHONY: build stop_development_environment run_development_environment deploy
