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
	@$(CONTAINER_RUNTIME) build \
	--file $(DOCKERFILES_PATH)/stage1.Dockerfile \
	--tag bannerbrawl-stage-1:v1.0 . --no-cache
build:
	@echo "Building image..."
	@$(CONTAINER_RUNTIME) build \
	--build-arg ZEROTIER_API_KEY=$(ZEROTIER_API_KEY) \
	--build-arg ZEROTIER_NETWORK_ID=$(ZEROTIER_NETWORK_ID) \
	--build-arg GAMEKEEPER_IP=$(GAMEKEEPER_IP) \
	--file $(DOCKERFILES_PATH)/Dockerfile \
	--tag $(IMAGE) . --no-cache
start:
	@echo "Starting container..."
	@docker-compose --file $(DOCKER_COMPOSE_PATH) up --detach
stop:
	@echo "Stopping container..."
	docker  compose --file $(DOCKER_COMPOSE_PATH) down 
clean:
	@echo "Removing image..."
	@until $(CONTAINER_RUNTIME) rmi $(IMAGE) \
	--namespace $(NAMESPACE) >/dev/null 2>&1; do \
		echo "Retrying in 10 seconds..."; \
		sleep 10; \
	done
