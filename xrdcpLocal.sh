#!/bin/bash

REDIR=$1
LFN=$2

FN=`echo ${LFN} | sed 's~/~_~g'`
FN=${FN:1:${#FN}-1}

echo $FN
xrdcp $REDIR$LFN $FN
