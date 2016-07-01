#!/bin/bash

image=${1:-agl-demo-platform}


echo $image

if [[ -d build ]]; then cd build; fi

export QEMU_UI_OPTIONS="-usb -usbdevice mouse"
exec runqemu \
	qemuparams="-m 512 -cpu Nehalem -smp 4" \
	qemux86-64 \
	tmp/deploy/images/qemux86-64/bzImage-qemux86-64.bin \
	tmp/deploy/images/qemux86-64/agl-demo-platform-qemux86-64.ext4 \
	serial \
	bootparams="uvesafb.mode_option=1024x768-32"

