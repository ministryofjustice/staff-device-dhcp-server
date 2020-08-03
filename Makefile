build:
	docker build -t docker_dhcp ./dhcp-service

stop_development_environment:
	docker-compose down -v

run_development_environment: stop_development_environment
	docker-compose up -d dhcp_config
	docker-compose up -d db
	./wait_for_db.sh
	docker-compose up --build -d dhcp

deploy: build
	echo ${REGISTRY_URL}
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_dhcp:latest ${REGISTRY_URL}/staff-device-${ENV}-dhcp-docker-dhcp:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dhcp-docker-dhcp:latest

.PHONY: build stop_development_environment run_development_environment deploy
