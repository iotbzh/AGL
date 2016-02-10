#!/bin/bash
#############################################################################
# When called this script will rewind the current directory until
# either it finds the file

cf=dev.conf

# or it reaches $HOME or /
# when the file $af is found, it is scanned to update the
# automatically created patches of name

af=auto.patch

# The format of $cf files is made of 3 fields separated with
# blanks. These fields are:
#
#  field 1: either + (to add the patch) or - (no patche)
#  field 2: the path to the bb or bbappend file to use for adding patches
#  field 3: the path the git directory of the project
#
# The option -s or --sync can be used to firstly synchronizes
# the SRCREV of the bbfiles with the version pushed on branch origin/master.

nosync=true
[[ "$1" = "-s" || "$1" = "--sync" ]] && nosync=false
branch="origin/master"

############################################################################
asaf="SRC_URI += \" file://$af\""

curbbver() {
	local bbf="$1"
	grep SRCREV "$bbf" | sed 's:.*"\(.*\)".*:\1:' | tr -d '\n'
}

curgitver() {
	local repo="$1"
	git --no-pager -C "$repo" log -n 1 --pretty=%H "$branch" | tr -d '\n'
}

mkpatch() {
	local bbf="$1"
	local repo="$2"
	local rev=$(curbbver "$bbf")
	git --no-pager -C "$repo" diff "$rev"
}

patchdir() {
	local d="$(dirname "$1")"
	local b="$(basename "$1")"
	local f
	for f in "${b%%_*}" "files"; do
		[[ -d "$d/$f" ]] && { echo -n "$d/$f"; return 0; }
	done
	return 1
}

patchfile() {
	local bbf="$1"
	echo -n "$(patchdir "$bbf")/$af"
}

syncvers() {
	local bbf="$1"
	local repo="$2"
	local bbv="$(curbbver "$bbf")"
	local gitv="$(curgitver "$repo")"
	[[ "$bbv" = "$gitv" ]] || {
		sed -i "s:$bbv:$gitv:" "$bbf"
		echo "revision synchronized for $bbf ($gitv)"
	}
}

delpatch() {
	local bbf="$1"
	local repo="$2"
	if grep -q "$asaf" "$bbf"; then
		grep -v "$asaf" "$bbf" > "$bbf.tmp" && mv "$bbf.tmp" "$bbf"
	fi
	rm "$(patchfile "$bbf")" 2> /dev/null
	echo "no patch for $bbf"
}

addpatch() {
	local bbf="$1"
	local repo="$2"
	$nosync || eval syncvers "$bbf" "$repo"
	local pf="$(patchfile "$bbf")"
	local pt="$(mkpatch "$bbf" "$repo")"
	if [[ -z "$pt" ]]; then
		delpatch "$bbf"
	else
		echo -n "$pt" > "$pf"
		if ! grep -q "$asaf" "$bbf"; then
			printf "$asaf" >> "$bbf"
		fi
		echo "patch made for $bbf"
	fi
}

process() {
	local line
	while read line; do
		set -- $line
		[[ "$#" = "3" && "$1" = "+" ]] && eval addpatch "$2" "$3"
		[[ "$#" = "3" && "$1" = "-" ]] && eval delpatch "$2" "$3"
	done
}

# this loops from current working dir to its parents until a file $cf is found
while :; do
	[[ -f "$cf" ]] && { echo "processing $PWD/$cf"; process < "$cf"; exit; }
	[[ "$PWD" = "$HOME" ]] && break
	[[ "$PWD" = "/" ]] && break;
	cd .. || break;
done

