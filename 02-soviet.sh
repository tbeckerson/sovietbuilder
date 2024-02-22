#! /bin/bash

## explode immediately if something breaks
set -e

###########
# this script checks a list of package names, and installs them
# using the cccp installer from the host system
###########

## compares complete list of programs (prog-list)
## with list that's been successfully built (build-progress)
## makes a new list with un-completed programs
comm -3 <(sort prog-list) <(sort build-progress) > build-list

## loop through the todo list, build files
while read prog; do
echo "installing $prog"
## using the cccp package manager, install everything in the build-list
## 
cccp --verbose -pkg ${PWD}/ecmp/${prog}.ecmp
echo "$prog successfully installed"
echo "$prog" >> ${PWD}/build-progress
cat ${PWD}/build-progress
done < ${PWD}/build-list

## all done!
touch ${PWD}/02-complete
