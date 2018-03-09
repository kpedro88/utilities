#!/bin/bash -e

sort_report() {
	MODE=$1
	NAME=$2
	MODULE=$3
	IGREP=igreport_${NAME}.res
	IGSORT=igsorted_${NAME}_${MODULE}_${MODE}.res
	if [ "$MODE" == "self" ]; then
		awk -v module=${MODULE} 'BEGIN { total = 0; } { if(substr($0,0,1)=="["&&index($0,module)!=0) {print $0; total += $3;} } END { print "Total: "total } ' igreport_testNew.res | sort -n -r -k1 | awk '{ if(index($0,"Total: ")!=0){total=$0;} else{print $0;} } END { print total; }' > ${IGSORT} 2>&1
	elif [ "$MODE" == "desc" ]; then
		awk -v module=${MODULE} 'BEGIN { total = 0; } { if(substr($0,0,1)=="-"){good = 0;}; if(good&&length($0)>0){print $0; total += $3;}; if(substr($0,0,1)=="["&&index($0,module)!=0) {good = 1;} } END { print "Total: "total } ' ${IGREP} | sort -n -r -k1 | awk '{ if(index($0,"Total: ")!=0){total=$0;} else{print $0;} } END { print total; }' > ${IGSORT} 2>&1		
	fi
	echo "Produced ${IGSORT}"
}

CMD=""
NAME="test"
SORTSELF=()
SORTDESC=()
TARGET=""
ROOT=""

# todo: add mp, sqlite options
while getopts "c:n:t:s:d:r" opt; do
	case "$opt" in
		c) CMD=$OPTARG
		;;
		n) NAME=$OPTARG
		;;
		t) TARGET="-t $OPTARG"
		;;
		s) IFS="," read -a SORTSELF <<< "$OPTARG"
		;;
		d) IFS="," read -a SORTDESC <<< "$OPTARG"
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
IGREP=igreport_${NAME}.res
# subshell to log commands but avoid `set +x`
(set -x;
igprof -d $TARGET -pp -z -o ${IGNAME}.pp.gz ${CMD} > ${IGNAME}.log 2>&1;
igprof-analyse -d -v ${IGNAME}.pp.gz > ${IGREP} 2>&1;
)

echo "Produced ${IGREP}"

# find producers/filters/analyzers, make sorted list & total
for MODULE in ${SORTSELF[@]}; do
	sort_report self ${NAME} ${MODULE}
done
for MODULE in ${SORTDESC[@]}; do
	sort_report desc ${NAME} ${MODULE}
done

