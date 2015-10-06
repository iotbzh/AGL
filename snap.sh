#/bin/bash
#
# This script extracts the git configuration of the subdirectories
# of the current directory and prints it on the standard output.
# This configuration can then be restored using the script snap-set.sh

LANG=
list=$(echo $PWD/*/.git)

#----------------------------------------
# check that repos are on clean commits
clean=true
for x in $list
do
  if [[ -d $x ]]
  then
    cd $x/..
    n=$(basename $PWD)
    if git status --porcelain -b | grep -qv '^##'
    then
      clean=false
      echo "error: submodule $n has local modication(s):" >&2
      git status -s | sed "s#^.. #   &$n/#" >&2
    fi
  fi
done
$clean || exit 1

#----------------------------------------
# emit the repo state
for x in $list
do
  if [[ -d $x ]]
  then
    cd $x/..
    n=$(basename $PWD)
    b=$(git status --porcelain -b | sed 's:\.\.\..*::' | awk '{print $2}')
    c=$(git log --pretty=format:%h -1)
    r=$(git remote -v | awk '{print $1"="$2}' | sort -u)
    printf "%-20s %-20s     " "$c=$b" "$n"
    echo $r
  fi
done


