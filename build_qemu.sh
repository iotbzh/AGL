#!/bin/bash

git submodule init
git submodule update
export TEMPLATECONF=$PWD/meta-agl-demo/conf
source poky/oe-init-build-env
bitbake agl-demo-platform
