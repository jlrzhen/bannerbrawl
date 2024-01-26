default: build

# Defaults
SERVICE_NAME=kingtower
CONTAINER_RUNTIME=docker
DOCKERFILE_PATH=kingtower

# Image
IMAGE_NAME=bannerbrawl-$(SERVICE_NAME)
IMAGE_TAG=v1.0
IMAGE=$(IMAGE_NAME):$(IMAGE_TAG)

# Shortcuts
help:
	@grep '^[^#[:space:]][^=]*:' Makefile
reload: stop start

# Build
build:
	@echo "Building image..."
	$(CONTAINER_RUNTIME) build \
	--build-arg ZEROTIER_API_KEY=$(ZEROTIER_API_KEY) \
	--build-arg ZEROTIER_NETWORK_ID=$(ZEROTIER_NETWORK_ID) \
	-f $(DOCKERFILE_PATH)/Dockerfile \
	-t $(IMAGE) . --no-cache
start:
	@echo "Starting container..."
	cd $(DOCKERFILE_PATH) && docker-compose up --detach
stop:
	@echo "Stopping container..."
	cd $(DOCKERFILE_PATH) && docker compose down
clean:
	@echo "Removing image..."
	@until $(CONTAINER_RUNTIME) rmi $(IMAGE) --namespace $(NAMESPACE) >/dev/null 2>&1; do \
		echo "Retrying in 10 seconds..."; \
		sleep 10; \
	done
