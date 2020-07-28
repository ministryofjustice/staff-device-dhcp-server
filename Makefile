build:
	docker build -t docker_dhcp ./dhcp-service

stop_development_environment:
	docker-compose down -v

run_development_environment: stop_development_environment build
	docker build -t docker_dhcp_config ./dhcp-config
	docker-compose up -d db
	./wait_for_db.sh
	docker-compose up dhcp-config
	docker-compose up -d dhcp

deploy:
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_dhcp:latest ${REGISTRY_URL}/docker_dhcp:latest
	docker push ${REGISTRY_URL}/docker_dhcp:latest

.PHONY: build stop_development_environment run_development_environment deploy
