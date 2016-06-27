#!/bin/bash
#
#  eosdu
#
#  Created by Jesus Orduna on 3/9/16.
#

# This will sum the size of all content inside the LFN and return the number in B
# or an empty string for empty directories
#function getSizeOf {
#    for theDir in $(eos root://cmseos.fnal.gov find $1 | awk '{print $0" "substr($0,length,1)}' | grep \ / | cut -d \  -f1) ; do
#        eos root://cmseos.fnal.gov ls -l $theDir
#    done | awk '{ sum+=$5} END {print sum}'
#}
function getSizeOf {
    eos root://cmseos.fnal.gov find $1 | grep "/$" | xargs -n1 -P4 eos root://cmseos.fnal.gov ls -l | awk '{ sum+=$5} END {print sum}'
}

function printSizeOf {
	DIR=$1

	# Get the size of the LFN
	theSize=$(getSizeOf $DIR)

	# Empty directories will evaluate true
	if [ "a$theSize" = "a" ] ; then
		echo "Empty"
	else
		# Non-empty directories with content adding zero-size will evaluate true
		# need to be filtered as log($theSize) will complain
		if [ "$theSize" -eq "0" ] ; then
			echo "0 B"
		elif [ -z "$HUMAN" ]; then
			echo ${theSize}
		else
			# Compute an index to refer to B, kB, MB, GB or TB
			declare -a thePrefix=( [0]="" [1]="K"  [2]="M" [3]="G" [4]="T" [5]="P" [6]="E" [7]="Z" [8]="Y")
			theIndex=$(awk "BEGIN {print int(log($theSize)/(10*log(2)))}")

			echo "$theSize $theIndex ${thePrefix[$theIndex]}" | awk '{print $1/(2^(10*$2))$3}'
		 fi
	fi
}

DIR=$1
HUMAN=$2

#"wildcard" option
if [[ "${DIR: -1}" == "*" ]]; then
	DIR="${DIR:0:$((${#DIR}-1))}"
	for i in $(eos root://cmseos.fnal.gov find --maxdepth 1 $DIR | grep "/$"); do
		if [[ "$i" == "$DIR" || "$i" == /eos/uscms"$DIR" ]]; then
		    continue
        fi
		theSize=$(printSizeOf $i)
		echo "`basename $i` $theSize"
	done
else
	printSizeOf $DIR
fi
