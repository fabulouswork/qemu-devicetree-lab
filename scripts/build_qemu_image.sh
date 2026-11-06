#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
mkdir -p "${PROJECT_DIR}/build"
LOG_FILE="${PROJECT_DIR}/build/build_qemu_image-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1
printf 'Logging output to %s\n' "${LOG_FILE}"

BUILDROOT_DIR="${PROJECT_DIR}/buildroot"
BUILDROOT_REPOSITORY="https://github.com/buildroot/buildroot.git"

if [[ ! -d "${BUILDROOT_DIR}/.git" && ! -f "${BUILDROOT_DIR}/.git" ]]; then
    if [[ -d "${BUILDROOT_DIR}" ]] && [[ -n "$(find "${BUILDROOT_DIR}" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
        printf 'Error: %s exists and is not an empty Buildroot checkout.\n' "${BUILDROOT_DIR}" >&2
        exit 1
    fi

    git clone --depth 1 "${BUILDROOT_REPOSITORY}" "${BUILDROOT_DIR}"
fi

make -C "${BUILDROOT_DIR}" qemu_aarch64_virt_defconfig
make -C "${BUILDROOT_DIR}"