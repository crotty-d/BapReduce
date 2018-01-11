#! /bin/bash

# Check that an argument (filename) is provided (-z "$1" => length of $1 string > 0)
if [ -z "$1" ]; then
    echo "$0 requires a filename as its (only) argument."
    exit 1
fi

#Switch working directory to mutex directory
cd mutex

# Try create link to input file ($1) that will lock the file against writing, but if not successful (exit code != 0) sleep for 1 sec and try again
while ! ln -s lock "$1-lock" 2>/dev/null; do
    sleep 0.1
done

#Switch working directory back to mains
cd ..
#Exit script normally
exit 0
