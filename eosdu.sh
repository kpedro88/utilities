#!/bin/bash
#
#  eosdu
#
#  Created by Jesus Orduna and Kevin Pedro
#

# This will sum the size of all content inside the LFN and return the number in B
# or an empty string for empty directories
function getSizeOf {
	eos root://cmseos.fnal.gov find -d $1 | xargs -I ARG -d '\n' -n1 -P4 bash -c 'awk "$0" <(eos root://cmseos.fnal.gov ls -l $1)' '{sum+=$5} END {print sum}' ARG | awk '{sum+=$0} END {print sum}'
}

# This does the same, but counts number of files
function getFilesOf {
	eos root://cmseos.fnal.gov find -d $1 | xargs -d '\n' -n1 -P4 eos root://cmseos.fnal.gov ls | wc -l | awk '{sum+=$0} END {print sum}'
}

function printSizeOf {
	DIR=$1

	# Get the size of the LFN
	if [ -z "$FILES" ]; then
		theSize=$(getSizeOf $DIR)
	else
		theSize=$(getFilesOf $DIR)
	fi

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
			# Compute an index to refer to B, kB, MB, GB, TB, PB, EB, ZB, YB
			declare -a thePrefix=( [0]="" [1]="K"  [2]="M" [3]="G" [4]="T" [5]="P" [6]="E" [7]="Z" [8]="Y")
			
			#decimal for size or files
			theIndex=$(awk "BEGIN {print int(log($theSize)/(3*log(10)))}")
			echo "$theSize $theIndex ${thePrefix[$theIndex]}" | awk '{print $1/(10^(3*$2))$3}'
		 fi
	fi
}

HUMAN=""
FILES=""
RECURSE=""

#check arguments
while getopts "fhr" opt; do
	case "$opt" in
	f) FILES=yes
	;;
	h) HUMAN=yes
	;;
	r) RECURSE=yes
	;;
	esac
done

shift $(($OPTIND - 1))
DIR=$1

#"recursive" option
if [[ -n "$RECURSE" ]]; then
	for i in $(eos root://cmseos.fnal.gov find -d --maxdepth 1 $DIR); do
		if [[ "$i" == "$DIR" || "$i" == /eos/uscms"$DIR" || "$i" == "$DIR"/ || "$i" == /eos/uscms"$DIR"/ || "$i" == root://cmseos.fnal.gov//eos/uscms"$DIR" || "$i" == root://cmseos.fnal.gov//eos/uscms"$DIR"/ ]]; then
			continue
		fi
		theSize=$(printSizeOf $i)
		echo "`basename $i` $theSize"
	done
else
	printSizeOf $DIR
fi
