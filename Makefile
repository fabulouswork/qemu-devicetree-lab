.DEFAULT_GOAL := help

IMAGE_NAME := qemu-devicetree-lab
PROJECT_DIR := $(CURDIR)
EXPERIMENT ?=

.PHONY: all help docker-build docker-run qemu-image qemu-run qemu-dts deploy-experiment dts-to-dtb qemu-run-with-dtb

all: qemu-image

help:
	@printf '%s\n' \
		'make docker-build  Build the Docker image' \
		'make docker-run    Start an interactive Docker container' \
		'make qemu-image    Build the QEMU image inside a temporary container' \
		'make qemu-run      Start QEMU using the existing image' \
		'make qemu-dts      Generate the QEMU device tree source' \
		'make deploy-experiment EXPERIMENT=<path.dts>  Copy the selected DTS to build/virt.dts' \
		'make dts-to-dtb    Convert the device tree source to a DTB' \
		'make qemu-run-with-dtb  Start QEMU with the generated DTB' \
		'  EXPERIMENT=<path.dts>  Deploy and compile this relative DTS path before starting QEMU' \
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
	./scripts/start-qemu.sh
	
qemu-dts:
	qemu-system-aarch64 \
		-M virt,dumpdtb=build/virt.dtb \
		-cpu cortex-a53 \
		-nographic \
		-smp 1 \
		-kernel buildroot/output/images/Image \
		-append "rootwait root=/dev/vda console=ttyAMA0" \
		-netdev user,id=eth0 \
		-device virtio-net-device,netdev=eth0 \
		-drive file=buildroot/output/images/rootfs.ext4,if=none,format=raw,id=hd0 \
		-device virtio-blk-device,drive=hd0
	dtc -I dtb -O dts -o build/virt.dts build/virt.dtb

deploy-experiment:
	@test -n "$(EXPERIMENT)" || { printf '%s\n' 'Specify EXPERIMENT=<relative-path.dts>.' >&2; exit 1; }
	@test -f "$(EXPERIMENT)" || { printf '%s\n' "Experiment not found: $(EXPERIMENT)" >&2; exit 1; }
	mkdir -p build
	cp "$(EXPERIMENT)" build/virt.dts

dts-to-dtb: 
	@if [ -f build/virt.dtb ]; then \
		printf '%s\n' 'Backing up build/virt.dtb to build/virt.dtb.bak...'; \
		cp build/virt.dtb build/virt.dtb.bak; \
	fi
	@printf '%s\n' 'Converting DTS to DTB...'
	dtc -I dts -O dtb -o build/virt.dtb build/virt.dts

qemu-run-with-dtb: 
ifneq ($(strip $(EXPERIMENT)),)
	$(MAKE) deploy-experiment
	$(MAKE) dts-to-dtb
endif
	./scripts/start-qemu.sh -dtb build/virt.dtb
	