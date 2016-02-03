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
############################################################################
asaf="SRC_URI += \" file://$af\""

mkpatch() {
	local bbf="$1"
	local repo="$2"
	local rev=$(grep SRCREV "$bbf" | tr -d ' "' | sed 's:.*=::')
	(cd $repo ; git --no-pager diff "$rev")
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

delpatch() {
	local bbf="$1"
	if grep -q "$asaf" "$bbf"; then
		grep -v "$asaf" "$bbf" > "$bbf.tmp" && mv "$bbf.tmp" "$bbf"
	fi
	rm "$(patchfile "$bbf")" 2> /dev/null
	echo "no patch for $bbf"
}

addpatch() {
	local bbf="$1"
	local repo="$2"
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

while :; do
	[[ -f "$cf" ]] && { echo "processing $PWD/$cf"; process < "$cf"; exit; }
	[[ "$PWD" = "$HOME" ]] && break
	[[ "$PWD" = "/" ]] && break;
	cd .. || break;
done

