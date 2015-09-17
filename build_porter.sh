#!/bin/bash

git submodule init
git submodule update

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
bitbake agl-demo-platform
