#!/bin/bash

#First check that an appropriate number of arguments has been entered: if not, print error and exit with exit code 1.
if [ $# -ne 1 ]; then
  echo "$0 requires exactly one argument"
  exit 1
fi

#input
key_file=$1

#Count of instances of key (lines in key_file)
count_keys=0
while read -r line; do
    ((count_keys++))
done < "$key_file"

#Send key and count to job master
#First lock reduce_pipe against inputs from other reduce processes
./p.sh reduce_pipe
#Critical section
echo ${key_file#*/} $count_keys > reduce_pipe
#Release lock
./v.sh reduce_pipe

#Exit script
exit 0
