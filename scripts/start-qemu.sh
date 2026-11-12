#!/bin/sh
BUILDROOT_IMAGE_DIR="./buildroot/output/images"
CALLER_DIR=$(pwd)
# shellcheck disable=SC2164
cd "${BUILDROOT_IMAGE_DIR}"

mode_serial=false
mode_sys_qemu=false
DTB_FILE=
ROOTFS_FILE=rootfs.ext4
KERNEL_EXTRA_ARGS=
while [ "$1" ]; do
    case "$1" in
    --serial-only|serial-only) mode_serial=true; shift;;
    --use-system-qemu) mode_sys_qemu=true; shift;;
    -dtb)
        if [ "$#" -lt 2 ] || [ -z "$2" ]; then
            echo "missing file for -dtb" >&2
            exit 1
        fi
        DTB_FILE=$2
        case "$DTB_FILE" in
            /*) ;;
            *) DTB_FILE="${CALLER_DIR}/${DTB_FILE}" ;;
        esac
        shift 2;;
    --rootfs)
        if [ "$#" -lt 2 ] || [ -z "$2" ]; then
            echo "missing file for --rootfs" >&2
            exit 1
        fi
        ROOTFS_FILE=$2
        case "$ROOTFS_FILE" in
            /*) ;;
            *) ROOTFS_FILE="${CALLER_DIR}/${ROOTFS_FILE}" ;;
        esac
        shift 2;;
    --kernel-append)
        if [ "$#" -lt 2 ] || [ -z "$2" ]; then
            echo "missing arguments for --kernel-append" >&2
            exit 1
        fi
        KERNEL_EXTRA_ARGS=$2
        shift 2;;
    --) shift; break;;
    *) echo "unknown option: $1" >&2; exit 1;;
    esac
done

if [ -n "$DTB_FILE" ]; then
    set -- -dtb "$DTB_FILE" "$@"
fi

if ${mode_serial}; then
    EXTRA_ARGS='-nographic'
else
    EXTRA_ARGS=''
fi

if ! ${mode_sys_qemu}; then
    export PATH="/workspace/buildroot/output/host/bin:${PATH}"
fi

exec qemu-system-aarch64 -M virt -cpu cortex-a53 -nographic -smp 1 -kernel "Image" -append "rootwait root=/dev/vda console=ttyAMA0 ${KERNEL_EXTRA_ARGS}" -netdev user,id=eth0 -device virtio-net-device,netdev=eth0 -drive file="${ROOTFS_FILE}",if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0  ${EXTRA_ARGS} "$@"
