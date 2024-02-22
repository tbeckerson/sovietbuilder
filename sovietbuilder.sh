#! /bin/bash

## explode immediately if something breaks
set -e

## start us off by tracking time
SECONDS=0
DURATION=$SECONDS
echo "Started: $(date)" > build-time

## we need a build number for some customization,
## and to create unique dates for sysupdate
if [ -f $PWD/build ]; then
BUILD="$(cat $PWD/build)";
else
BUILD="$(date +%y%m%d)"
echo $BUILD > $PWD/build
fi

##############
## The next three variables are the only ones that need to be changed.
## location of the new build of soviet
## default is $PWD/$BUILD-build
SOV_DIR="$PWD/build-$BUILD"
## where the pre-built files used in the 3rd script are stored
## default is $PWD/soviet-files
SOV_FILES="$PWD/soviet-files"
## where you want the final img files to be stored
## default is $PWD/$BUILD-files
SOV_BUILD="$PWD/$BUILD-files"
#############

## figure out the number of available processors,
## defaults to procs -1 so the system still has resources
NPROCS=$(nproc)
if [ $NPROCS -eq 1 ]
then
MAKEFLAGS=" -j1 ";
else
MAKEFLAGS=" -j$((NPROCS-1))"; ## change this line if needed
fi

## make the base filesystem
if [ ! -f $PWD/01-complete ]; then
source ./01-dirs.sh &&
fi

## use cccp to install soviet
if [ -f $PWD/01-complete ] && [ ! -f $PWD/02-complete ]; then
source 02-soviet.sh &&
fi

## copy relevant files to the new install
if [ -f $PWD/02-complete ] && [ ! -f $PWD/03-complete ]; then
source 03-files.sh &&
fi

## nspawn to enter the system and run configs
if [ -f $PWD/03-complete ] && [ ! -f $PWD/04-complete ]; then
systemd-nspawn -D $SOV_DIR /04-config.sh &&
## create a check file in the host system
if [ -f $SOV_DIR/04-complete ]; then
touch $PWD/04-complete
 
## make the deliverables
if [ -f $PWD/04-complete ] && [ ! -f $PWD/05-complete ]; then
source 05-build.sh &&
fi

## remove the build file so we get a fresh start next time
rm $PWD/build
## remove build status files made in 02
rm $PWD/build-{progress,list}
## clear out the check files
rm $PWD/*-complete
## get a final time for the build
echo "SOVIET LINUX, build $BUILD\nFinished: $(date)\nTime elapsed: $($DURATION / 60)M $($DURATION % 60)S" >> "$BUILD-build-time"
