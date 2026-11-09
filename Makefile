.DEFAULT_GOAL := help

IMAGE_NAME := qemu-devicetree-lab
PROJECT_DIR := $(CURDIR)

.PHONY: all help docker-build docker-run qemu-image qemu-run

all: qemu-image

help:
	@printf '%s\n' \
		'make docker-build  Build the Docker image' \
		'make docker-run    Start an interactive Docker container' \
		'make qemu-image    Build the QEMU image inside a temporary container' \
		'make qemu-run      Start QEMU using the existing image' \
		'make all           Build the Docker image and then the QEMU image'

docker-build:
	./docker/build_docker.sh

docker-run: docker-build
	./docker/run_docker.sh

qemu-image: docker-build
	docker run --rm --name $(IMAGE_NAME)-build \
		--volume "$(PROJECT_DIR)":/workspace \
		$(IMAGE_NAME) /workspace/scripts/build_qemu_image.sh

qemu-run:
	./buildroot/output/images/start-qemu.sh
