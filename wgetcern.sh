#!/bin/bash

URL=$1
cookie=~/private/ssocookie.txt
cern-get-sso-cookie --krb -r -u $URL -o $cookie
wget -nv -e robots=off -nH --cut-dirs=10  --load-cookies=$cookie --save-cookies=$cookie --no-check-certificate -r --no-parent $URL
