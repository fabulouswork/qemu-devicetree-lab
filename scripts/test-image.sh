#!/usr/bin/env bash

prepare_test_image() {
    qemu-img convert -f raw -O raw buildroot/output/images/rootfs.ext4 "$1"
    if e2fsck -p "$1"; then
        :
    else
        local result=$?
        if [ "$result" -ne 1 ]; then
            echo "Failed to check the copied guest filesystem (exit $result)" >&2
            return "$result"
        fi
    fi
}
