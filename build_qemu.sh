#!/bin/bash

git submodule init
git submodule update
export TEMPLATECONF=$PWD/meta-agl-demo/conf
source poky/oe-init-build-env

# overload OE variable DL_DIR from environment
[ -d "$DL_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE DL_DIR"

# overload OE variable SSTATE_DIR from environment
[ -d "$SSTATE_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE SSTATE_DIR"

bitbake agl-demo-platform
