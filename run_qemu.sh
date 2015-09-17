#!/bin/sh

. poky/oe-init-build-env
runqemu qemux86-64 tmp/deploy/images/qemux86-64/agl-demo-platform-qemux86-64.ext4
