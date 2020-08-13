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

run: stop_development_environment start-db
	$(DOCKER_COMPOSE) up --build dhcp

shell: start-db
	$(DOCKER_COMPOSE) run --rm dhcp bash

.PHONY: build stop_development_environment run_development_environment deploy
