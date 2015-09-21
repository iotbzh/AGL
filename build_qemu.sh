#!/bin/bash

# syntax:
#  add_upstream_remote <sub-directory> <git_repo_url>
function add_upstream_remote
{
	directory=$1
	repo=$2

	[ -d $directory ] && {
		cd $directory
		git remote -v | grep upstream > /dev/null ||
			git remote add upstream $repo
		cd - > /dev/null
	}
}

# Script entry point
git submodule init
git submodule update

# Register "upstream" remote for AGL layers
add_upstream_remote meta-agl https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl
add_upstream_remote meta-agl-demo https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl-demo
add_upstream_remote meta-renesas https://gerrit.automotivelinux.org/gerrit/AGL/meta-renesas

export TEMPLATECONF=$PWD/meta-agl-demo/conf
source poky/oe-init-build-env

# overload OE variable DL_DIR from environment
[ -d "$DL_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE DL_DIR"

# overload OE variable SSTATE_DIR from environment
[ -d "$SSTATE_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE SSTATE_DIR"

bitbake agl-demo-platform
