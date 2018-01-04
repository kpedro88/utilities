#!/bin/bash -e

case `uname` in
  Linux) ECHO="echo -e" ;;
  *) ECHO="echo" ;;
esac

usage() {
	$ECHO "wgetcern.sh [options] <url>"
	$ECHO
	$ECHO "Options:"
	$ECHO "--cert        \tw/ --key, use certificate access for CERN SSO (otherwise kerberos)"
	$ECHO "--key         \tw/ --cert, use certificate access for CERN SSO (otherwise kerberos)"
	exit 1
}

CERT=""
KEY=""
URL=""
while [ $# -gt 0 ]; do
	case $1 in
	--cert)
		CERT=$2
		shift; shift
	;;
	--key)
		KEY=$2
		shift; shift
	;;
	-*)
		$ECHO "Unknown option $1"
		exit 1
	;;
	*)
		if [ -n "$URL" ]; then
			$ECHO "Unexpected extra argument $1"
			exit 1
		fi
		URL=$1
		shift
	;;
	esac
done	

if [ -z "$URL" ]; then
	usage
fi

CONNECT=""
if [ -n "$CERT" ] && [ -n "$KEY" ]; then
	CONNECT="--cert $CERT --key $KEY"
elif [ -z "$CERT" ] && [ -z "$KEY" ]; then
	CONNECT="--krb"
else
	usage
fi

cookie=~/private/ssocookie.txt
cern-get-sso-cookie $CONNECT -r -u $URL -o $cookie
wget -nv -e robots=off -nH --cut-dirs=10  --load-cookies=$cookie --save-cookies=$cookie --no-check-certificate -r --no-parent $URL
