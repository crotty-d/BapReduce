# Bash MapReduce Engine

## Project aims

1. In Bash, implement a single-node MapReduce engine (‘job master’) that does the
following:

* Takes a repository of csv data files and a target attribute (column of the data) as input
and outputs a list of key–value pairs, each comprising a unique value (key) of the
attribute and the number times that value appears in the repository (value or count).

* Uses three core scripts to achieve this: a map process (mapper) to find and group all the
different instances of the attribute (e.g. product name) into separate files (key-files); a
reduce process (reducer) to take each key-file and count its contents, returning the key
and the count as a space-separated pair; and thirdly, a job master script to assign files to
the mapper and reducer and to coordinate and monitor their progress.

* Communication between the job master and the mapper/reducer should be via named
pipes.


2. In Bash, implement a fully distributed multi-node MapReduce engine that uses a ‘master
node’ to distribute data files between two job master nodes and runs them while monitoring
their progress and ensuring they work together efficiently without errors. To do this, the
master node should facilitate data transfer between the two job master nodes.

**__Note:** The multi-node engine (aim 2) has not yet been implemented so the project currently only addresses a single node engine (aim 1)__


## Running the scripts

### Single-node engine

First open a Bash terminal. To process a particular respository ('sales_data' for multiple files, or 'single_file_data' for single complete data file) and a particular attribute (column) of the data, run ./job_master.sh with the repository name (string) and the column number (integer) as arguments. For example, to perform a multi-file MapReduce on the sales data, targeting product names, cd to the 'program' directory and enter the following:

./job_master.sh sales_data 2

As well as being displayed in terminal, the completion of steps and output of various parameters is automatically logged to a file in the 'logs' directory (new log created for each run of the script).

### Multi-node engine

NOT IMPLEMENTED YET

### Testing

Run ./test_mapreduce.sh in the terminal to test split and single-file performance on product name and country attributes; and also single attribute performance on product number and credit card. It runs each MapReduce program (job_master.sh plus the given arguments) in sequence, displaying steps and values from the program as before. However, it also gives the completion time for each program via the Bash command 'time'. Of the three times provided, the 'real' time is the regular, real-world completion time. For easy performance comparison and recording, these completion times are logged to a corresponding file in the testing directory.


## Outline of key scripts (current state)

**Job Master (job_master.sh \[arg1\] \[arg2\])**

Setup
* First some initial housekeeping is done, particularly clearing temporary files.
* The arguments are assigned to the variables, ‘repo’ (directory containing files to map) and ‘column’ (attribute \[column number\] to target).
* Create logging function.

Map
* Count files in directory (repository) and assign value to variable.
* Start that number of mappers (map.sh) in background using one of the file paths as an argument.
* Listen to map_pipe to get key–value pairs (key 1) sent from mapper, to record each unique key found, and to determine when all files have been mapped.
* Check if keys are unique as coming in from mapper and , if so, write to ‘keys’ file using write_append.sh script.

Reduce
* Count lines in keys file get number of files to be reduced.
* Start that number of reducers (reduce.sh) in background.
* Listen to reduce_pipe to get each key-value pair (key count) from the reducers and to determine when all files have been reduced.

**Mapper (map.sh \[arg1\] \[arg2\])**

* The arguments are assigned to the variables, ‘file’ (file to map) and ‘column’ (attribute[column number] to target).
* Isolate (cut command) the instances of target keys (column) in the file to a temporary file in the 'instance_lists' directory.
* Read through instances file line-by-line and output contents to appropriate key file using write_key_file.sh script.
* Send key to job master via map_pipe
* Alert job master and log that the file mapping is complete

**Reducer (reduce.sh \[arg1\])**

* Take in file containing all instances of key as the argument and assign to the variable ‘key_file’
* Count key instances (lines in key_file)
* Send key and count to job master via the reduce_pipe
