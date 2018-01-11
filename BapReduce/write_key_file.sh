#!/bin/bash

#First check that an appropriate number of arguments has been entered: if not, print error and exit with exit code 1.
if [ $# -ne 1 ]; then
  echo "$0 requires exactly one argument"
  exit 1
fi

#Apply lock (so only write to file if not being written to)
./p.sh "$1"
#Critical section where writing occurs
if [ ! -e "mapped_sorted/$1" ]; then
    echo $1 1 > "mapped_sorted/$1"
else
    echo $1 1 >> "mapped_sorted/$1"
fi
#Release lock
./v.sh "$1"

#Exit script normally
exit 0
