build:
	docker build -t docker_dhcp ./dhcp-service

stop_development_environment:
	docker-compose down -v

run_development_environment: stop_development_environment
	docker-compose up -d db
	./wait_for_db.sh
	docker-compose up --build dhcp-config
	docker-compose up --build -d dhcp

deploy: build
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL} --registry-ids ${TARGET_AWS_ACCOUNT_ID}
	docker tag docker_dhcp:latest ${REGISTRY_URL}/staff-device-${ENV}-dhcp-docker-dhcp:latest
	docker push ${REGISTRY_URL}/staff-device-${ENV}-dhcp-docker-dhcp:latest

.PHONY: build stop_development_environment run_development_environment deploy
