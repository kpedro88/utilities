#!/bin/bash

git status -suno | while read mode file; do echo $mode $(stat -c %y $file) $file; done|sort -k1.4
