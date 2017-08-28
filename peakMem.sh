#!/bin/bash

if [ -z "$1" ]; then
	exit 1
fi

# line looks like this: MemoryCheck: event : VSIZE 1269.24 0 RSS 864.18 0

grep "MemoryCheck: event" $1 | awk '{if($5>maxv){maxv=$5;}; if($8>maxr){maxr=$8;}} END {print "peak VSIZE: " maxv "\npeak   RSS: " maxr}'
