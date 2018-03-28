#!/bin/bash

USER=$1
if [ -z "$USER" ]; then
	USER=pedrok
fi

AWKCMD='{ split($0,a," "); j1 += a[1]; j2 += a[3]; j3 += a[5]; j4 += a[7]; j5 += a[9]; j6 += a[11]; j7 += a[13];} END { print j1,"jobs;",j2,"completed,",j3,"removed,",j4,"idle,",j5,"running,",j6,"held,",j7,"suspended"}'
GREPCMD="completed"

CONDORV=$(condor_q -version | grep CondorVersion | awk '{print $2}')
IFS="." read -a CONDORVARRAY <<< "$CONDORV"

if [ "${CONDORVARRAY[0]}" -ge 8 ] && [ "${CONDORVARRAY[1]}" -ge 6 ]; then
	AWKCMD='{ split($0,a," "); j1 += a[4]; j2 += a[6]; j3 += a[8]; j4 += a[10]; j5 += a[12]; j6 += a[14]; j7 += a[16];} END { print j1,"jobs;",j2,"completed,",j3,"removed,",j4,"idle,",j5,"running,",j6,"held,",j7,"suspended"}'
	GREPCMD="query"
fi

condor_q -submitter $USER -totals | grep -F "$GREPCMD" | grep -vF "all users" | awk "$AWKCMD"

