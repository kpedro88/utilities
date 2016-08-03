#!/bin/bash

function getPkgStatus(){
	PKG=$1
	DIRLOG=$(grep $PKG $LOG)
	if $(echo "$DIRLOG" | fgrep -q -m1 "built"); then
		echo 2
	elif $(echo "$DIRLOG" | fgrep -q -m1 "Compiling"); then
		echo 1
	else
		echo 0
	fi
}
export -f getPkgStatus

export LOG=$1
if [[ -z $LOG || ! -f $LOG ]]; then
  exit
fi

echo "scram status:"
find . -maxdepth 2 -mindepth 2 -type d -wholename "*/*" -not -path '*/\.*' -printf '%P\0' | xargs -0 -n1 -P4 bash -c 'getPkgStatus "$@"' _ | awk 'BEGIN {ctr[0] = 0; ctr[1] = 0; ctr[2] = 0;} {ctr[$1]++;total++} END {collen=length(total); printf(" in progress: %*s / %*s\n",collen,ctr[1],collen,total); printf("    finished: %*s / %*s\n",collen,ctr[2],collen,total);}'
