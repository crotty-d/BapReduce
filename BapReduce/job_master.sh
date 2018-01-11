#!/bin/bash

#First check that an appropriate number of arguments has been entered: if not, print error and exit with exit code 1.
if [ $# -ne 2 ] ; then
    echo "$0 requires a single directory name (repository of files) and the number of the column nwhere the where the keys reside"
    exit 1
fi

#----------------------------
# Setup
#----------------------------

#Ensure mutex directory empty; no locks set
rm -r mutex
mkdir mutex
touch mutex/lock

#Clear temporary directories and files before starting
rm -r mapped_sorted
mkdir mapped_sorted
rm -r instance_lists
mkdir instance_lists
rm keys
touch keys
rm reduced
touch reduced

#Input
repo="$1" #Directory containing files to map
column=$2 #Attribute (column number of data file) to target

#Logging output
#Log path
file_time="$(echo $(date +"%Y-%m-%d %T"))"
logpath="logs/log_${repo}_col${column} ($file_time).txt"
#Function to write to log and terminal
function log {
    log_time="$(echo $(date +"%Y-%m-%d %T"))"
    echo $log_time -- $1
    echo $log_time -- $1 >> "$2"
}

#----------------------------
# Map
#----------------------------

#Count files in directory (repository) and assign value to variable
n_map=$(ls $repo | wc -l)
msg="Number of map jobs to assign: $n_map"
log "$msg" "$logpath"

#Start mappers in background
for file in $repo/*; do
    ./map.sh "$file" $column &
    msg="$file sent to mapper"
    log "$msg" "$logpath"
done

#Listen to map_pipe to get each unique key found and to determine when all files have been mapped
#Initialize count variable and array of unique keys
count_mapped=0
unique_keys=()
while true; do
    if [ $count_mapped -lt $n_map ]; then
        read input < map_pipe
        if [[ "$input" = *"has been mapped" ]]; then
            ((count_mapped++))
            msg="$input: $count_mapped now complete"
            log "$msg" "$logpath"
        else
            #echo Job master received $input #uncomment to see 'live stream' from mappers
            #Write key to keys file, but only  if new (unique)
            if [[ "${unique_keys[@]}" = *"$input"* ]]; then
                :
            else
                ./write_append.sh keys "$input"
                unique_keys+=("${input#*/}")
                msg="New key found: $input"
                log "$msg" "$logpath"
            fi
        fi
    else
       break
   fi
done

#----------------------------
# Reduce
#----------------------------

reduce_dir="mapped_sorted"

#Total files to be reduced
#Count lines in keys and assign value to variable
n_reduce=0
while read -r line; do
    ((n_reduce++))
done < keys
msg="Number of reduce jobs to assign: $n_reduce"
log "$msg" "$logpath"

#Start reducers in background
for file in "$reduce_dir"/*; do
    ./reduce.sh "$file" &
    msg="$file sent to reducer"
    log "$msg" "$logpath"
done

#Listen to reduce_pipe to get each key-value pair from the reducers and to determine when all files have been reduced
count_reduced=0
while true; do
    if [ $count_reduced -lt $n_reduce ]; then
        read input < reduce_pipe
        ./write_append.sh reduced "$input"
        ((count_reduced++))
        msg="Received reduced key-value pair (count): "$input""
        log "$msg" "$logpath"
    else
        break
    fi
done

#Exit script
msg="Job_master finished."
log "$msg" "$logpath"
exit 0
