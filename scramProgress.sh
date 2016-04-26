#!/bin/bash

LOG=$1
if [[ -z $LOG || ! -f $LOG ]]; then
  exit
fi

COUNTER=0
FOUND=0
INPROG=0

for dir in `ls -d */*/`; do
#  echo $dir
  #remove trailing /
  dir=$(echo $dir | rev | cut -c 2- | rev)
  COUNTER=$(($COUNTER + 1))
  DIRLOG=$(grep $dir $LOG)
  if $(echo "$DIRLOG" | fgrep -q "built"); then
    FOUND=$(($FOUND + 1))
  elif $(echo "$DIRLOG" | fgrep -q "Compiling"); then
    INPROG=$(($INPROG + 1))
  fi
done

echo "scram status:"
echo "in progress: $INPROG / $COUNTER"
echo "   finished: $FOUND / $COUNTER"
