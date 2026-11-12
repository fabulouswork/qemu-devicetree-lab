#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <device-tree.dts>" >&2
    exit 1
fi

for tool in qemu-img e2fsck debugfs dtc timeout; do
    command -v "$tool" >/dev/null || { echo "Required tool not found: $tool" >&2; exit 1; }
done

source ./scripts/test-image.sh
tmpdir=$(mktemp -d)
trap 'rm -f "$tmpdir/rootfs.ext4" "$tmpdir/virt.dtb" "$tmpdir/check" "$tmpdir/console.log"; rmdir "$tmpdir"' EXIT

prepare_test_image "$tmpdir/rootfs.ext4"
dtc -I dts -O dtb -o "$tmpdir/virt.dtb" "$1"

for entry in "drivers/dtlab_driver/output/dtlab_driver.ko:dtlab-test.ko" "scripts/test-driver-init.sh:dtlab-test-init"; do
    source=${entry%%:*}
    destination=${entry#*:}
    debugfs -w -R "write $source /$destination" "$tmpdir/rootfs.ext4"
    debugfs -R "dump /$destination $tmpdir/check" "$tmpdir/rootfs.ext4"
    cmp "$source" "$tmpdir/check" || { echo "Failed to copy $source into the guest image" >&2; exit 1; }
    rm "$tmpdir/check"
done
debugfs -w -R "set_inode_field /dtlab-test-init mode 0100755" "$tmpdir/rootfs.ext4"

echo "Starting QEMU driver test (timeout: 180 seconds)..."
if timeout 180 ./scripts/start-qemu.sh --rootfs "$tmpdir/rootfs.ext4" \
    --kernel-append "rw init=/dtlab-test-init" -dtb "$tmpdir/virt.dtb" \
    -- -no-reboot 2>&1 | tee "$tmpdir/console.log"; then
    :
else
    result=$?
    echo "QEMU test or console logging failed or timed out (exit $result)" >&2
    exit "$result"
fi

if ! grep -q '^DTLAB_TEST: PASS' "$tmpdir/console.log" ||
   grep -q '^DTLAB_TEST: FAIL:' "$tmpdir/console.log"; then
    echo "Driver test failed" >&2
    exit 1
fi
