build:
	docker build -t docker_dhcp ./dhcp-service

stop_development_environment:
	docker-compose down -v

run_development_environment: stop_development_environment build
	docker build -t docker_dhcp_config ./dhcp-config
	docker-compose up -d db
	./wait-for-it.sh localhost:3306
	docker-compose up dhcp-config
	docker-compose up -d dhcp

deploy:
	echo ${REGISTRY_PASSWORD} | docker login --username ${REGISTRY_USERNAME} --password-stdin ${REGISTRY_URL}
	docker tag docker_dhcp:latest ${REGISTRY_URL}/docker_dhcp:latest
	docker push ${REGISTRY_URL}/docker_dhcp:latest
