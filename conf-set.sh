#!/bin/sh
#
# This script restores the files bblayers.conf and local.conf
# of the subdirectory build/conf according to the value given
# in input. The value at input must be a value saved by the command
# conf.sh.
# The pattern ##OEROOT## is replaced with the directory containing
# build/conf.
# Previous files bblayers.conf and local.conf are saved in files
# bblayers.conf~ and local.conf~

build=${1:-build}
[ -d ../$build ] && cd ..
if [ ! -d $build/conf ]; then
	echo "can't found directory build/conf" >&2
	exit 1
fi

here=$PWD
cd $build/conf

tmp=$(mktemp)
trap "[ -f $tmp ] && rm $tmp" INT QUIT TERM EXIT

sed "s:##OEROOT##:$here:g" > $tmp

subfile() {
  if grep -q "^$1 " $tmp; then
    [ -f "$1" ] && mv "$1" "$1~"
    grep "^$1 " $tmp | sed "s:^$1 ::" > "$1"
  fi
}

subfile bblayers.conf
subfile local.conf
rm $tmp

