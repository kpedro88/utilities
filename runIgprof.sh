#!/bin/bash -e

CMD=""
NAME="test"

# todo: add mp, sqlite options
while getopts "c:n:" opt; do
	case "$opt" in
		c) CMD=$OPTARG
		;;
		n) NAME=$OPTARG
		;;
	esac
done

if [ -z "$CMD" ]; then
	echo "-c required"
	exit 1
fi

IGNAME=igprof_${NAME}
IGREP=igreport_${NAME}
igprof -d -pp -z -o ${IGNAME}.pp.gz ${CMD} > ${IGNAME}.log 2>&1
igprof-analyse -d -v ${IGNAME}.pp.gz > ${IGREP}.res 2>&1

echo "Produced ${IGREP}.res"

