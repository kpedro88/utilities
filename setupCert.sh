#!/bin/bash -e

case `uname` in
	Linux) ECHO="echo -e" ;;
	CYGWIN*) ECHO="echo -e" ;;
	*) ECHO="echo" ;;
esac

usage(){
	$ECHO "setupCert.sh [options] [user@server] [p12 file]"
	$ECHO
	$ECHO "Options:"
	$ECHO "-c        \tset up for cern-get-sso-cookie"
	$ECHO "-d        \tdry run (just print commands, don't execute)"

	exit 1
}

COOKIE=""
DRYRUN=""

while getopts "cd" opt; do
	case "$opt" in
		c) COOKIE=true
		;;
		d) DRYRUN=true
		;;
	esac
done

shift $(($OPTIND - 1))
SERVER=$1
P12=$2

if [ -z "$P12" ] || [ -z "$SERVER" ]; then
	usage
else
	P12BASE=$(basename $P12)
fi

CMD1="scp $P12 $SERVER:~/"
CMD2b="mkdir -p .globus; rm -f .globus/usercert.pem .globus/userkey.pem .globus/userkey.rsa; openssl pkcs12 -in $P12BASE -clcerts -nokeys -out .globus/usercert.pem; openssl pkcs12 -in $P12BASE -nocerts -out .globus/userkey.pem; chmod 400 .globus/usercert.pem; chmod 400 .globus/userkey.pem"
if [ -n "$COOKIE" ]; then
  CMD2b="$CMD2b; openssl rsa -in .globus/userkey.pem -out .globus/userkey.rsa; chmod 400 .globus/userkey.rsa"
fi
CMD2="ssh -t $SERVER '"$CMD2b"'"

if [ -n "$DRYRUN" ]; then
	$ECHO "dry run:"
	$ECHO "$CMD1"
	$ECHO "$CMD2"
else
	eval "$CMD1"
	eval "$CMD2"
fi
