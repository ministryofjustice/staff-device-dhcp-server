DOCKER_COMPOSE = docker-compose -f docker-compose.yml

authenticate-docker:
	./scripts/authenticate_docker.sh

check-container-registry-account-id:
	./scripts/check_container_registry_account_id.sh

build: check-container-registry-account-id
	docker build -t dhcp ./dhcp-service --build-arg SHARED_SERVICES_ACCOUNT_ID

build-nginx:
	docker build -t nginx ./nginx --build-arg SHARED_SERVICES_ACCOUNT_ID

push-nginx:
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag nginx:latest ${REGISTRY_URL}/staff-device-${ENV}-dhcp-nginx:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dhcp-nginx:latest

push:
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag dhcp:latest ${REGISTRY_URL}/staff-device-${ENV}-dhcp:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dhcp:latest

publish: build push build-nginx push-nginx

deploy:
	./scripts/deploy.sh

build-dev:
	$(DOCKER_COMPOSE) build

start-db: check-container-registry-account-id
	$(DOCKER_COMPOSE) up -d db
	./scripts/wait_for_db.sh

stop:
	$(DOCKER_COMPOSE) down -v

run: start-db
	$(DOCKER_COMPOSE) up -d dhcp-primary
	./scripts/wait_for_dhcp_server.sh
	$(DOCKER_COMPOSE) up -d dhcp-standby
	$(DOCKER_COMPOSE) up -d dhcp-api

test: run build-dev
	./scripts/wait_for_dhcp_server.sh
	$(DOCKER_COMPOSE) run --rm dhcp-test rspec ./metrics/spec
	$(DOCKER_COMPOSE) run --rm dhcp-test bash ./dhcp_test.sh

shell: start-db
	$(DOCKER_COMPOSE) run --rm dhcp-primary sh

shell-test: start-db
	$(DOCKER_COMPOSE) run --rm dhcp-test sh

logs:
	$(DOCKER_COMPOSE) logs --follow

implode:
	$(DOCKER_COMPOSE) rm

.PHONY: build push publish deploy build-dev start-db stop run test shell shell-test logs implode authenticate-docker check-container-registry-account-id build-nginx push-nginx
