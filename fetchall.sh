#/bin/bash

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
# fetch the remotes
for x in $list
do
  if [[ -d $x ]]
  then
    cd $x/..
    r=$(git remote -v | awk '{print $1}' | sort -u)
    for g in $r
    do
      echo ----- $PWD
      echo git fetch -p -t $g
      git fetch -p -t $g
    done
  fi
done


