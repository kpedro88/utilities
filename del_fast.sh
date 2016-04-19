#!/bin/bash

DIRTODEL=$1

if [[ -z $1 ]]; then
  echo "No directory specified"
  exit 0
fi

EMPTYDIR="empty"`date +%s%N`

mkdir $EMPTYDIR
echo "deleting ${DIRTODEL} with rsync..."
rsync -a --delete ${EMPTYDIR}/ ${DIRTODEL}/
rm -rf ${EMPTYDIR}
rm -rf ${DIRTODEL}
