include .env

build:
	docker build -t docker_dhcp ./dhcp-service

deploy:
	echo ${REGISTRY_PASSWORD} | docker login --username ${REGISTRY_USERNAME} --password-stdin ${REGISTRY_URL}
	docker tag docker_dhcp:latest ${REGISTRY_URL}/docker_dhcp:latest
	docker push ${REGISTRY_URL}/docker_dhcp:latest

run_all:
	docker-compose up --build -V
