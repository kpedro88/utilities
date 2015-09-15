#!/bin/bash

condor_q -submitter pedrok | grep -F "completed" | awk '{ split($0,a," "); j1 += a[1]; j2 += a[3]; j3 += a[5]; j4 += a[7]; j5 += a[9]; j6 += a[11]; j7 += a[13];} END { print j1,"jobs;",j2,"completed,",j3,"removed,",j4,"idle,",j5,"running,",j6,"held,",j7,"suspended"}'

