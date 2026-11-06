
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

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

# Clone the official Buildroot repository
RUN git clone --depth 1 https://github.com/buildroot/buildroot.git /opt/buildroot

# Set Buildroot as the working directory
WORKDIR /opt/buildroot

# Default shell
CMD ["/bin/bash"]
