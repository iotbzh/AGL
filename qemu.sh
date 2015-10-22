#!/bin/bash

image=${1:-agl-demo-platform}


echo $image

if [[ -d build ]]; then cd build; fi
cd tmp/deploy/images/qemux86-64
qemu-system-x86_64 \
  -cpu qemu64,+ssse3 -m 512 -usb \
  -k fr -serial stdio \
  --append "root=/dev/hda security=smack console=ttyS0" \
  -kernel bzImage-qemux86-64.bin \
  -hda ${image}-qemux86-64.ext3
