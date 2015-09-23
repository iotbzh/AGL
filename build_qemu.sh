#!/bin/bash

source env.sh

# Register "upstream" remote for AGL layers
git_add_remote_upstream meta-agl https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl
git_add_remote_upstream meta-agl-demo https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl-demo
git_add_remote_upstream meta-renesas https://gerrit.automotivelinux.org/gerrit/AGL/meta-renesas

export TEMPLATECONF=$PWD/meta-agl-demo/conf
source poky/oe-init-build-env

# overload OE variable DL_DIR from environment
[ -d "$DL_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE DL_DIR"

# overload OE variable SSTATE_DIR from environment
[ -d "$SSTATE_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE SSTATE_DIR"

bitbake agl-demo-platform
