#!/bin/bash

#Where to log results
file_time="$(echo $(date +"%Y-%m-%d %T"))"
path="testing/mapreduce_runtimes ($file_time).txt"

function time_script {
    repo=$1
    col=$2
    scenario=$3

    echo $scenario
    echo -e "\n$scenario" >> "$path"
    echo Running script $snum...
    { time ./job_master.sh "$repo" $col ; } 2>> "$path"
    echo
}

#-----------------------
#Run and time scripts
#-----------------------

#Run and time scripts

#Single-file data: products
time_script "single_file_data" 2 "Single-file data: MapReduce products (column 2) for single-file sales_data"

#Split data: products
time_script "sales_data" 2 "Split data: MapReduce products (column 2) for multi-file (split) sales_data"

#Single-file data: countries
time_script "single_file_data" 8 "Single-file data: MapReduce countries (column 8) for single-file sales_data"

#Split data:countries
time_script "sales_data" 8 "Split data: MapReduce countries (column 8) for multi-file (split) sales_data"

#product numbers
time_script "sales_data" 3 "MapReduce product numbers (column 3) for multi-file (split) sales_data"

#credit cards
time_script "sales_data" 4 "MapReduce credit cards (column 4) for multi-file (split) sales_data"

#Finish and exit
echo Testing finished
echo -e "\nTesting finished" >> "$path"
exit 0
