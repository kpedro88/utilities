#!/bin/bash

sort -r -n -k5 <(condor_userprio -allusers)
