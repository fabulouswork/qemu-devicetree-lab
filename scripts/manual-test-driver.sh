#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ] || [ -z "$1" ]; then
    echo "Specify DRIVER=drivers/<directory>." >&2
    exit 1
fi

drivers_dir=$(realpath -e drivers)
driver=$(realpath -e -- "$1") || { echo "Driver directory not found: $1" >&2; exit 1; }
case "$driver/" in
    "$drivers_dir/"*) ;;
    *) echo "Driver must be a directory inside drivers/: $1" >&2; exit 1 ;;
esac
if [ ! -d "$driver" ] || [ ! -f "$driver/Makefile" ]; then
    echo "Driver directory must contain a Makefile: $1" >&2
    exit 1
fi

for tool in qemu-img e2fsck debugfs; do
    command -v "$tool" >/dev/null || { echo "Required tool not found: $tool" >&2; exit 1; }
done
if [ -n "$2" ]; then
    command -v dtc >/dev/null || { echo "Required tool not found: dtc" >&2; exit 1; }
fi

make -C "$driver"
if [ -n "$3" ]; then
    module=$(realpath -e -- "$3") || { echo "Module not found: $3" >&2; exit 1; }
    case "$module" in
        "$driver/"*.ko) ;;
        *) echo "MODULE must be a .ko file inside the selected driver directory: $3" >&2; exit 1 ;;
    esac
    [ -f "$module" ] || { echo "Module is not a regular file: $3" >&2; exit 1; }
else
    mapfile -d '' -t modules < <(find "$driver" -type f -name '*.ko' -print0)
    if [ "${#modules[@]}" -ne 1 ]; then
        echo "Expected one .ko file under $1; found ${#modules[@]}. Select one with MODULE=<path.ko>." >&2
        exit 1
    fi
    module=${modules[0]}
fi

source ./scripts/test-image.sh
tmpdir=$(mktemp -d)
trap 'rm -f "$tmpdir/rootfs.ext4" "$tmpdir/virt.dtb" "$tmpdir/module.ko" "$tmpdir/check"; rmdir "$tmpdir"' EXIT

prepare_test_image "$tmpdir/rootfs.ext4"
cp "$module" "$tmpdir/module.ko"
debugfs -w -R "write \"$tmpdir/module.ko\" /manual-test.ko" "$tmpdir/rootfs.ext4"
debugfs -R "dump /manual-test.ko \"$tmpdir/check\"" "$tmpdir/rootfs.ext4"
cmp "$tmpdir/module.ko" "$tmpdir/check" || { echo "Failed to copy the module into the guest image" >&2; exit 1; }

qemu_args=(--rootfs "$tmpdir/rootfs.ext4")
if [ -n "$2" ]; then
    dtc -I dts -O dtb -o "$tmpdir/virt.dtb" "$2"
    qemu_args+=(-dtb "$tmpdir/virt.dtb")
fi

printf '\nGuest module: /manual-test.ko (from %s)\n' "$module"
printf 'After logging in, run: insmod /manual-test.ko\n\n'
./scripts/start-qemu.sh "${qemu_args[@]}"
