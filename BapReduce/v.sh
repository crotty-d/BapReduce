#!/bin/bash

#Check that an argument (filename) is provided (-z "$1" => length of $1 string > 0)
if [ -z "$1" ]; then
    echo "$0 requires a filename as its (only) argument."
    exit 1
fi

#Switch working directory to mutex directory
cd mutex

#Rename (atomic) and then delete link (non-atomic) to input file ($1) that is locking the file against writing
#Note: Sometimes another v process will get in and rename and remove before this rm operation completes generating an error. However, this is harmless as it's after the atomic remname operation (protective part) of v; therefore errors are suppressed for v.
mv "$1-lock" "$1-delete" && rm "$1-delete" 2>/dev/null

#Switch working directory back to main
cd ..
#Exit script normally
exit 0
