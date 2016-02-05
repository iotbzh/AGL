#!/bin/bash

image=${1:-agl-demo-platform}


echo $image

if [[ -d build ]]; then cd build; fi

exec runqemu \
	qemux86-64 \
	tmp/deploy/images/qemux86-64/bzImage-qemux86-64.bin \
	tmp/deploy/images/qemux86-64/agl-demo-platform-qemux86-64.ext4 \
	serial

