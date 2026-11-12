#!/bin/sh

fail() {
    echo "DTLAB_TEST: FAIL: $*" >/dev/console
    poweroff -f
    while :; do sleep 60; done
}

mount -t proc proc /proc || fail "cannot mount proc"
mount -t sysfs sysfs /sys || fail "cannot mount sysfs"
insmod /dtlab-test.ko || fail "cannot load module"
test -L /sys/bus/platform/drivers/dtlab/dtlab || fail "driver did not bind to the device"
dmesg | grep 'Device Tree laboratory driver probed!' || fail "probe message not found"
echo "DTLAB_TEST: PASS" >/dev/console
poweroff -f
while :; do sleep 60; done
