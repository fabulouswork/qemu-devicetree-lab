ifneq ($(KERNELRELEASE),)
obj-m += dtlab_driver.o
else

PROJECT_DIR := $(abspath ../..)
BUILDROOT_DIR := $(PROJECT_DIR)/buildroot
BUILDROOT_CONFIG := $(BUILDROOT_DIR)/.config
KERNEL_VERSION := $(shell sed -n 's/^BR2_LINUX_KERNEL_VERSION="\([^"]*\)"/\1/p' $(BUILDROOT_CONFIG))

KERNEL_DIR ?= $(BUILDROOT_DIR)/output/build/linux-$(KERNEL_VERSION)
MODULE_OUTPUT := $(CURDIR)/output
ARCH ?= arm64
CROSS_COMPILE ?= $(BUILDROOT_DIR)/output/host/bin/aarch64-buildroot-linux-gnu-

.PHONY: all modules clean

all: modules

modules:
	@test -f "$(BUILDROOT_CONFIG)" || { echo "Buildroot configuration not found: $(BUILDROOT_CONFIG)" >&2; exit 1; }
	@test -f "$(KERNEL_DIR)/Makefile" || { echo "Buildroot kernel build tree not found: $(KERNEL_DIR). Build the kernel with Buildroot first, or set KERNEL_DIR." >&2; exit 1; }
	$(MAKE) -C "$(KERNEL_DIR)" M="$(CURDIR)" MO="$(MODULE_OUTPUT)" ARCH="$(ARCH)" CROSS_COMPILE="$(CROSS_COMPILE)" modules

clean:
	@test -f "$(KERNEL_DIR)/Makefile" || { echo "Buildroot kernel build tree not found: $(KERNEL_DIR)." >&2; exit 1; }
	$(MAKE) -C "$(KERNEL_DIR)" M="$(CURDIR)" MO="$(MODULE_OUTPUT)" ARCH="$(ARCH)" CROSS_COMPILE="$(CROSS_COMPILE)" clean

endif