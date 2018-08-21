## Makefile
SHELL=/bin/bash

# Config options
NAME=docker-makefile-boilerplate
TAG=0.0-dev

# Docker options
BUILD_CONTEXT=.
DOCKERFILE=Dockerfile

# Network options
DEFAULT_NETWORK=docker-makefile-boilerplate-net
DEFAULT_SUBNET=10.10.10.0/24
DEFAULT_GATEWAY=10.10.10.1

all: build run
build: build-image build-network
clean: stop clean-container clean-network clean-image
clean-test: clean build test
status: status-image status-network status-container

build-image:
	@echo ">>> $@"
	docker build \
		-t="${NAME}:${TAG}" \
		-f="${DOCKERFILE}" \
		${BUILD_CONTEXT}
	@echo "=== $@ DONE\n"

build-network:
	@echo ">>> $@"
	docker network create \
		--driver="bridge" \
		--subnet="${DEFAULT_SUBNET}" \
		--ip-range="${DEFAULT_SUBNET}" \
		--gateway="${DEFAULT_GATEWAY}" \
		${DEFAULT_NETWORK}
	@echo "=== $@ DONE\n"

clean-container:
	@echo ">>> $@"
	-docker rm ${NAME}
	@echo "=== $@ DONE\n"

clean-image:
	@echo ">>> $@"
	-docker image rm ${NAME}:${TAG}
	@echo "=== $@ DONE\n"

clean-network:
	@echo ">>> $@"
	-docker network rm ${DEFAULT_NETWORK}
	@echo "=== $@ DONE\n"

run:
	@echo ">>> $@"
	docker run \
		-d \
		--name "${NAME}" \
		--net "${DEFAULT_NETWORK}" \
		--publish-all \
		${NAME}:${TAG}
	@echo "=== $@ DONE\n"

status-container:
	@echo ">>> $@"
	-docker container inspect ${NAME} --format '{{ .State.Running }}'
	@echo "=== $@ DONE\n"

status-image:
	@echo ">>> $@"
	-docker image inspect ${NAME}:${TAG} --format '{{ .Created }}'
	@echo "=== $@ DONE\n"

status-network:
	@echo ">>> $@"
	-docker network inspect ${DEFAULT_NETWORK} --format '{{ .Created }}'
	@echo "=== $@ DONE\n"

stop:
	@echo ">>> $@"
	-docker stop ${NAME}
	@echo "=== $@ DONE\n"

test:
	@echo ">>> $@"
	docker run \
		-it \
		--rm \
		--name "${NAME}_TEST-CONFIG" \
		${NAME}:${TAG} /usr/sbin/nginx -t -c /etc/nginx/nginx.conf
	@echo "=== $@ DONE\n"
