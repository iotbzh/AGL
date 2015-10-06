#!/bin/sh
#
# This script extracts the files bblayers.conf and local.conf
# from the subdirectory build/conf and print it to the standard
# output. The pattern ##OEROOT## replace the directory containing
# build/conf.
# The saved configuration can be restored by the script conf-set.sh

[ -d ../build ] && cd ..
if [ ! -d build/conf ]; then
	echo "can't found directory build/conf" >&2
	exit 1
fi

here=$PWD
cd build/conf

subfile() {
  [ -f "$1" ] && sed "s:^:$1 :" "$1"
}

{
  subfile bblayers.conf
  subfile local.conf
} |
sed "s:$here:##OEROOT##:g"
