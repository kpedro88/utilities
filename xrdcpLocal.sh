#!/bin/bash

REDIR=""
LFN=""
OUTDIR="./"
FORCE=""
QUIET=""

while getopts "fqx:L:o:" opt; do
	case "$opt" in
	f) FORCE="-f"
	;;
	q) QUIET="-q"
	;;
	x) REDIR=$OPTARG
	;;
	L) LFN=$OPTARG
	;;
	o) OUTDIR=$OPTARG
	;;
	esac
done

if [ -z "$REDIR" ]; then
	echo "Must specify redirector with -x"
	exit 1
fi

if [ -z "$LFN" ]; then
	echo "Must specify LFN with -L"
	exit 1
fi

FN=`echo ${LFN} | sed 's~/~_~g'`
FN=${FN:1:${#FN}-1}

echo $FN
xrdcp $FORCE $QUIET $REDIR$LFN $OUTDIR$FN
