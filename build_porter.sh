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

#porter section
echo -e "\n"
echo -e "Please download these 2 files from \"http://www.renesas.com/secret/r_car_download/rcar_demoboard.jsp\" and copy them into your \"$HOME\" directory:"
echo -e "* R-Car_Series_Evaluation_Software_Package_for_Linux-20150727.zip"
echo -e "* R-Car_Series_Evaluation_Software_Package_of_Linux_Drivers-20150727.zip"
echo -e "and press [ENTER] to continue...\n"
read
mkdir binary-tmp
cd binary-tmp
unzip -o "$HOME/R-Car_Series_Evaluation_Software_Package_for_Linux-20150727.zip"
unzip -o "$HOME/R-Car_Series_Evaluation_Software_Package_of_Linux_Drivers-20150727.zip"
cd ../meta-renesas/meta-rcar-gen2
./copy_gfx_software_porter.sh ../../binary-tmp
./copy_mm_software_lcb.sh ../../binary-tmp
cd ../..

export TEMPLATECONF=$PWD/meta-renesas/meta-rcar-gen2/conf
source poky/oe-init-build-env

# overload OE variable DL_DIR from environment
[ -d "$DL_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE DL_DIR"

# overload OE variable SSTATE_DIR from environment
[ -d "$SSTATE_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE SSTATE_DIR"

bitbake agl-demo-platform
