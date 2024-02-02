default: build

# Defaults
SERVICE_NAME=kingtower
CONTAINER_RUNTIME=docker
DOCKER_COMPOSE_PATH=./$(SERVICE_NAME)/compose.yaml
DOCKERFILES_PATH="./Dockerfiles"

# Image
IMAGE_NAME=bannerbrawl-base
IMAGE_TAG=v1.0
IMAGE=$(IMAGE_NAME):$(IMAGE_TAG)

# Shortcuts
help:
	@grep '^[^#[:space:]][^=]*:' Makefile
reload: stop start

# Build
build_stage_1:
	@echo "Building base image..."
	@$(CONTAINER_RUNTIME) build \
	--file $(DOCKERFILES_PATH)/stage1.Dockerfile \
	--tag bannerbrawl-stage-1:$(IMAGE_TAG) . --no-cache
build:
	@echo "Building box image..."
	@$(CONTAINER_RUNTIME) build \
	--build-arg ZEROTIER_API_KEY=$(ZEROTIER_API_KEY) \
	--build-arg ZEROTIER_NETWORK_ID=$(ZEROTIER_NETWORK_ID) \
	--build-arg GAMEKEEPER_IP=$(GAMEKEEPER_IP) \
	--file $(DOCKERFILES_PATH)/Dockerfile \
	--tag $(IMAGE) . --no-cache
build_gamekeeper:
	@echo "Building gamekeeper image..."
	@$(CONTAINER_RUNTIME) build \
	--build-arg ZEROTIER_API_KEY=$(ZEROTIER_API_KEY) \
	--build-arg ZEROTIER_NETWORK_ID=$(ZEROTIER_NETWORK_ID) \
	--build-arg GAMEKEEPER_IP=$(GAMEKEEPER_IP) \
	--file ./gamekeeper/Dockerfile \
	--tag bannerbrawl-gamekeeper:$(IMAGE_TAG) . --no-cache
start:
	@echo "Starting container..."
	docker compose --file $(DOCKER_COMPOSE_PATH) up --detach
stop:
	@echo "Stopping container..."
	docker compose --file $(DOCKER_COMPOSE_PATH) down 
clean:
	@echo "Removing image..."
	@until $(CONTAINER_RUNTIME) rmi $(IMAGE) \
	--namespace $(NAMESPACE) >/dev/null 2>&1; do \
		echo "Retrying in 10 seconds..."; \
		sleep 10; \
	done
purge:
	docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
