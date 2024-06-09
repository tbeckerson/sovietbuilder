#! /bin/bash

## explode immediately if something breaks
set -e

###########
# this script checks a list of package names, and installs them
# using the cccp installer from the host system
###########
## git an updated OUR base tree
if [[ ! -d /var/cccp/sources/OUR ]]; then
git clone -C /var/cccp/sources/ https://github.com/Soviet-Linux/OUR.git
else
( cd /var/cccp/sources/OUR
git pull )
fi

## grab the list of programs to install
cp $SOV_FILES/prog-list .
## touch some files to avoid an error
if [[ ! -f build-{progress,list} ]]; then
touch build-{progress,list}
fi
## compares full list of programs (prog-list)
## with list that's been successfully built (build-progress)
## makes a new list with programs to build (build-list)
comm -3 <(prog-list) <(build-progress) > build-list

## loop through the todo list, build files
while read PROG; do
## using the cccp package manager, install everything in the build-list
cccp --verbose --overwrite -Nn -i $PROG
## when the program is installed, add the name to build-progress file
echo "$PROG" >> build-progress
## read the file
cat tail -1 build-progress
## finish the loop, continue with contents of build-list
done < build-list

#PROGS=$(cat build-list)
#for PROG in $PROGS; do 
#cccp --verbose --overwrite -n -i $PROG
#echo $PROG >> build-progress
#done

## all done!
touch 02-complete
