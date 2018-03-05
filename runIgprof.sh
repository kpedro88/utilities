#!/bin/bash -e

CMD=""
NAME="test"
SORT=""
TARGET=""
ROOT=""

# todo: add mp, sqlite options
while getopts "c:n:t:sr" opt; do
	case "$opt" in
		c) CMD=$OPTARG
		;;
		n) NAME=$OPTARG
		;;
		t) TARGET="-t $OPTARG"
		;;
		s) SORT=true
		;;
		r) ROOT=true
		;;
	esac
done

if [ -z "$CMD" ]; then
	echo "-c required"
	exit 1
fi

# special way to run a ROOT macro (otherwise difficult due to quote nesting)
if [ -n "$ROOT" ]; then
	CMD="root.exe -b -l -q $CMD"
fi

IGNAME=igprof_${NAME}
IGREP=igreport_${NAME}
igprof -d $TARGET -pp -z -o ${IGNAME}.pp.gz ${CMD} > ${IGNAME}.log 2>&1
igprof-analyse -d -v ${IGNAME}.pp.gz > ${IGREP}.res 2>&1

echo "Produced ${IGREP}.res"

# find producers/filters/analyzers, make sorted list & total
if [ -n "$SORT" ]; then
	IGSORT=igsorted_${NAME}
	awk 'BEGIN { total = 0; } { if(substr($0,0,1)=="-"){good = 0;}; if(good&&length($0)>0){print $0; total += $3;}; if(substr($0,0,1)=="["&&index($0,"doEvent")!=0) {good = 1;} } END { print "Total: "total } ' ${IGREP}.res | sort -n -r -k1 | awk '{ if(index($0,"Total: ")!=0){total=$0;} else{print $0;} } END { print total; }' > ${IGSORT}.res 2>&1
	echo "Produced ${IGSORT}.res"
fi

