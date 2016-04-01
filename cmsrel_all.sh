#!/bin/bash

ls -dt /cvmfs/cms.cern.ch/slc*/cms/cmssw/CMSSW_* /cvmfs/cms.cern.ch/slc*/cms/cmssw-patch/CMSSW_* | grep $1
