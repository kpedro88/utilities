#!/bin/bash -e

case `uname` in
	Linux) ECHO="echo -e" ;;
	*) ECHO="echo" ;;
esac

usage(){
	$ECHO "xrdcpLocal.sh [options]"
	$ECHO
	$ECHO "Options:"
	$ECHO "-x        \tredirector (root://.../) (required)"
	$ECHO "-L        \tlogical file name (/store/...) (required)"
	$ECHO "-o        \toutput directory (default = pwd)"
	$ECHO "-f        \tforce (overwrite if file already exists at destination)"
	$ECHO "-q        \tquiet (don't print progress)"

	exit 1
}

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

if [ -z "$REDIR" ] || [ -z "$LFN" ]; then
	usage
fi

FN=`echo ${LFN} | sed 's~/~_~g'`
FN=${FN:1:${#FN}-1}

echo $FN
xrdcp $FORCE $QUIET $REDIR$LFN $OUTDIR$FN
