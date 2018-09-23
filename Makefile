################
### Makefile ###
################

# Traditional targets
.PHONY: all build build-docker build-post build-pre clean clean-all clean-docker clean-post clean-pre install install-docker install-post install-pre uninstall uninstall-docker uninstall-post uninstall-pre
# User targets
.PHONY: build-image clean-image clean-test install-network install-volume remove run status status-container status-image status-network status-volume stop test uninstall-network uninstall-volume

######################
### Config options ###
######################

# General options
SHELL=/bin/bash

# Config options
DOCKER_NAME=docker-makefile-boilerplate
DOCKER_TAG=0.0-dev

# Volume options
DOCKER_VOLUME_NAME=${DOCKER_NAME}-data
DOCKER_VOLUME_PATH=/data

# Docker options
DOCKER_BUILD_CONTEXT=.
DOCKER_BUILD_DOCKERFILE=Dockerfile

# Network options
DOCKER_NETWORK_EXTERNAL_IP=10.10.10.10
DOCKER_NETWORK_NAME=docker-makefile-boilerplate-net
DOCKER_NETWORK_SUBNET=10.10.10.0/24
DOCKER_NETWORK_GATEWAY=10.10.10.1

###########################
### Operational targets ###
###########################

# Traditional targets 
all: build install run
build: build-pre build-docker build-post
clean: stop remove uninstall clean-pre clean-docker clean-post
clean-all: clean
install: install-pre install-docker install-post
uninstall: stop remove uninstall-pre uninstall-docker uninstall-post
# build the docker contianer
build-pre:
build-docker: build-image
build-post:
# remove the container
clean-pre:
clean-docker: clean-image
clean-post:
# set up volumes, networks, etc
install-pre:
install-docker: install-network install-volume
install-post:
# remove volumes, networks, etc
uninstall-pre:
uninstall-docker: uninstall-network uninstall-volume
uninstall-post:
# special targets
clean-test: clean build test
status: status-container status-network status-volume status-image

############################
### User-defined targets ###
############################

build-image:
	@echo ">>> $@: Building image..."
	docker build \
		-t="${DOCKER_NAME}:${DOCKER_TAG}" \
		-f="${DOCKER_BUILD_DOCKERFILE}" \
		${DOCKER_BUILD_CONTEXT}
	@echo "=== $@ DONE\n"

clean-image:
	@echo ">>> $@: Removing image..."
	-docker image rm ${DOCKER_NAME}:${DOCKER_TAG}
	@echo "=== $@ DONE\n"

install-network:
	@echo ">>> $@: Creating networks..."
	docker network create \
		--driver="bridge" \
		--subnet="${DOCKER_NETWORK_SUBNET}" \
		--ip-range="${DOCKER_NETWORK_SUBNET}" \
		--gateway="${DOCKER_NETWORK_GATEWAY}" \
		${DOCKER_NETWORK_NAME}
	@echo "=== $@ DONE\n"

install-volume:
	@echo ">>> $@: Creating volumes..."
	@echo "=== $@ DONE\n"

remove:
	@echo ">>> $@: Removing containers..."
	-docker rm ${DOCKER_NAME}
	@echo "=== $@ DONE\n"

run:
	@echo ">>> $@: Running containers..."
	docker run \
		-d \
		--name "${DOCKER_NAME}" \
		--net "${DOCKER_NETWORK_NAME}" \
		--publish "${DOCKER_NETWORK_EXTERNAL_IP}:80:80" \
		--mount "type=volume,src=${DOCKER_VOUME_NAME},dst=${DOCKER_VOLUME_PATH}" \
		${DOCKER_NAME}:${DOCKER_TAG}
	@echo "=== $@ DONE\n"

status-container:
	@echo ">>> $@: Status: Container"
	-docker container inspect ${DOCKER_NAME} --format '{{ .State.Running }}'
	@echo "=== $@ DONE\n"

status-image:
	@echo ">>> $@: Status: Image"
	-docker image inspect ${DOCKER_NAME}:${DOCKER_TAG} --format '{{ .Created }}'
	@echo "=== $@ DONE\n"

status-network:
	@echo ">>> $@: Status: Network"
	-docker network inspect ${DOCKER_NETWORK_NAME} --format '{{ .Created }}'
	@echo "=== $@ DONE\n"

status-volume:
	@echo ">>> $@: Status: Volume"
	-docker volume inspect ${DOCKER_VOLUME_NAME} --format '{{ .CreatedAt }}'
	@echo "=== $@ DONE\n"

stop:
	@echo ">>> $@: Stopping containers..."
	-docker stop ${DOCKER_NAME}
	@echo "=== $@ DONE\n"

test:
	@echo ">>> $@: Testing configuration..."
	docker run \
		-it \
		--rm \
		--name "${DOCKER_NAME}_TEST-CONFIG" \
		${DOCKER_NAME}:${DOCKER_TAG} /usr/sbin/nginx -t -c /etc/nginx/nginx.conf
	@echo "=== $@ DONE\n"

uninstall-network:
	@echo ">>> $@: Removing networks..."
	-docker network rm ${DOCKER_NETWORK_NAME}
	@echo "=== $@ DONE\n"

uninstall-volume:
	@echo ">>> $@: Removing volumes..."
	-docker volume rm ${DOCKER_VOLUME_NAME}
	@echo "=== $@ DONE\n"
