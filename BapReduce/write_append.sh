#!/bin/bash

#First check that an appropriate number of arguments has been entered: if not, print error and exit with exit code 1.
if [ $# -ne 2 ]; then
  echo "$0 requires exactly two arguments"
  exit 1
fi

#Inputs
file="$1"
text="$2"

#Apply lock (so only write to file if not being written to)
./p.sh "$1"
#Critical section where writing occurs
    echo $text >> $file
 #Release lock
./v.sh "$1"

#Exit script normally
exit 0
