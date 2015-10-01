#!/bin/bash

source env.sh

function usage {
	printf "Usage:\t`basename $0` target-name [build-outdir]\n\n"
	printf "\t\ttarget-name:\t\"qemu\", \"porter\" or \"silk\"\n"
	printf "\t\tbuild-outdir:\t(opt.) \"build\" by default.\n"
	exit 1
}

#----------------------------------------
# Catch command line arguments
if [[ ! ( $# -eq 1 || $# -eq 2 ) ]]; then
	usage
fi

TARGET=$1
shift

if [ -z $1 ]; then
	OUTDIR="build"
else
	OUTDIR="build-$1"
fi

#----------------------------------------
# Target specific stuff
case $TARGET in
	qemu)
		export TEMPLATECONF=$PWD/meta-agl-demo/conf
		;;
	porter)
		copy_mum_zip porter
		export TEMPLATECONF=$PWD/meta-renesas/meta-rcar-gen2/conf
		;;
	silk)
		copy_mum_zip silk
		# FIXME: export TEMPLATECONF=$PWD/meta-renesas/meta-rcar-gen2/conf
		;;
	*)
		echo "Invalid target."
		usage
		;;
esac

#----------------------------------------
# Import open-embedded environment
source poky/oe-init-build-env $OUTDIR

# overload OE variable DL_DIR from environment
[ -d "$DL_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE DL_DIR"

# overload OE variable SSTATE_DIR from environment
[ -d "$SSTATE_DIR" ] &&
	export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE SSTATE_DIR"

## echo "Copy/paste following to launch build:"
## echo "    bitbake agl-demo-platform"
## echo 
echo "Starting a sub-shell" # (if not, environment will be lost)
exec /bin/bash --norc -l

