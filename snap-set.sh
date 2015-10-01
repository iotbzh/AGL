#/bin/bash

LANG=
here="$PWD"
awk '{ print "DIR  "$2; for(i=3;i<=NF;i++) { print "REPO "$i}; print "HASH "$1 }' |
while read tag value
do
  case $tag in
  DIR)
    [[ -d "$here/$value" ]] || mkdir "$here/$value"
    [[ -d "$here/$value/.git" ]] || git init "$here/$value"
    echo ========= $value ==============
    cd "$here/$value"
    ;;
  REPO)
    name="${value%%=*}"
    url="${value#*=}"
    if ! git remote | grep -q "^$name\$"
    then
      git remote add "$name" "$url"
    elif ! git remote -v | awk '$1=="'$name'" && $2!="'$url'" {exit 1}'
    then
      git remote set-url "$name" "$url"
    fi
    ;;
  HASH)
    sha="${value%%=*}"
    branch="${value#*=}"
    git fetch --all
    git checkout -f "$sha" -B "$branch"
    ;;
  esac
done

