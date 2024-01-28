default: build

# Defaults
SERVICE_NAME=kingtower
CONTAINER_RUNTIME=docker
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
	-f $(DOCKERFILES_PATH)/stage1.Dockerfile \
	-t bannerbrawl-stage-1:v1.0 . --no-cache
build:
	@echo "Building image..."
	@$(CONTAINER_RUNTIME) build \
	--build-arg ZEROTIER_API_KEY=$(ZEROTIER_API_KEY) \
	--build-arg ZEROTIER_NETWORK_ID=$(ZEROTIER_NETWORK_ID) \
	--build-arg GAMEKEEPER_MEMBER_ID=$(GAMEKEEPER_MEMBER_ID) \
	-f $(DOCKERFILES_PATH)/Dockerfile \
	-t $(IMAGE) . --no-cache
start:
	@echo "Starting container..."
	cd $(SERVICE_NAME) && docker-compose up --detach
stop:
	@echo "Stopping container..."
	cd $(SERVICE_NAME) && docker compose down
clean:
	@echo "Removing image..."
	@until $(CONTAINER_RUNTIME) rmi $(IMAGE) --namespace $(NAMESPACE) >/dev/null 2>&1; do \
		echo "Retrying in 10 seconds..."; \
		sleep 10; \
	done
