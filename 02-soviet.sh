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
if [[ ! -f prog-list ]]; then
cp $SOV_FILES/prog-list .
fi
## touch some files to avoid an error
if [[ ! -f build-{progress,list} ]]; then
touch build-{progress,list}
fi
## compares full list of programs (prog-list)
## with list that's been successfully built (build-progress)
## makes a new list with programs to build (build-list)
comm --nocheck-order -3 prog-list build-progress > build-list

## loop through the todo list, build files
while read PROG; do
## using the cccp package manager, install everything in the build-list
cccp --verbose -dbg 4 -Nn -i $PROG | tee /var/cccp/log/$PROG.log &&
## some programs create this dir but doesn't delete it, and libspm fails
rm -rf $SOV_DIR/usr/share/info/dir
## when the program is installed, add the name to build-progress file
echo "$PROG" >> build-progress
## finish the loop, continue with contents of build-list
done < build-list

## would a for loop be better??
#PROGS=$(cat build-list)
#for PROG in $PROGS; do 
#cccp --verbose -dbg 4 -Nn -i $PROG | tee /var/cccp/log/$PROG.log &&
#echo $PROG >> build-progress
#done

## all done!
touch 02-complete
