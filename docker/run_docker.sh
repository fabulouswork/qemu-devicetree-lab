#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
mkdir -p "${PROJECT_DIR}/build"
LOG_FILE="${PROJECT_DIR}/build/run_docker-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1
printf 'Logging output to %s\n' "${LOG_FILE}"

if docker container inspect qemu-devicetree-lab >/dev/null 2>&1; then
    docker container rm --force qemu-devicetree-lab
fi

docker run -it --name qemu-devicetree-lab \
    --volume "${PROJECT_DIR}":/workspace \
    qemu-devicetree-lab