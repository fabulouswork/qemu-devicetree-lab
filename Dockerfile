
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG HOST_UID=1000
ARG HOST_GID=1000

# Install development tools and Buildroot dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    cpio \
    unzip \
    rsync \
    bc \
    file \
    python3 \
    libncurses-dev \
    qemu-system-arm \
    device-tree-compiler \
    ca-certificates \
    libssl-dev \
    libelf-dev \
    && rm -rf /var/lib/apt/lists/*

RUN if ! getent group "${HOST_GID}" >/dev/null; then groupadd --gid "${HOST_GID}" hostuser; fi \
    && if ! getent passwd "${HOST_UID}" >/dev/null; then useradd --uid "${HOST_UID}" --gid "${HOST_GID}" --create-home --shell /bin/bash hostuser; fi \
    && mkdir -p /home/hostuser \
    && mkdir -p /workspace \
    && chown "${HOST_UID}:${HOST_GID}" /home/hostuser /workspace

ENV HOME=/home/hostuser
USER ${HOST_UID}:${HOST_GID}
WORKDIR /workspace

# Default shell
CMD ["/bin/bash"]
