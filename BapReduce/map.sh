#!/bin/bash

#First check that an appropriate number of arguments has been entered: if not, print error and exit with exit code 1.
if [ $# -ne 2 ]; then
  echo "$0 requires exactly two arguments"
  exit 1
fi

#Input
file="$1" #file to map
column=$2 #attribute (column number of data file) to target

#Isolate instances of target keys (column) in the file
#to a temporary file in the 'instance_lists' directory
inst_file="instance_lists/${file#*/}_instances"
cut -d"," -s -f$column "$file" > "$inst_file"

#Read through keys_all line-by-line and output contents to appropriate key file
while read -r line; do
    ./write_key_file.sh "$line"
    #Send key to job master
    #First lock map_pipe against inputs from other map processes
    ./p.sh map_pipe
    #Critical section
    echo "$line" > map_pipe
    #Release lock
    ./v.sh map_pipe
done < "$inst_file"

#Alert job master and log that the file mapping is complete

#First lock map_pipe against inputs from other map processes
./p.sh map_pipe
#Critical section
echo "$file has been mapped" > map_pipe
#Release lock
./v.sh map_pipe

#Exit script
exit 0
