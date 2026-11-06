#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
mkdir -p "${PROJECT_DIR}/build"
LOG_FILE="${PROJECT_DIR}/build/build_docker-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1
printf 'Logging output to %s\n' "${LOG_FILE}"

docker build \
	--build-arg HOST_UID="$(id -u)" \
	--build-arg HOST_GID="$(id -g)" \
	--tag qemu-devicetree-lab \
	"${PROJECT_DIR}"