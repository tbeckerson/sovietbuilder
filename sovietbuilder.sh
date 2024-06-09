#! /bin/bash

## explode immediately if something breaks
set -e

## start us off by tracking time
SECONDS=0
DURATION=$SECONDS
if [ ! -f build-time ]; then
echo "Started: $(date)" > build-time
fi

## we need a build number for some customization,
## and to create unique dates for sysupdate
if [ -f build ]; then
BUILD="$(cat build)";
else
BUILD="$(date +%y%m%d%H%M)"
echo $BUILD > build
fi

##############
## The next four variables are the only ones that need to be changed.
## location of the new build of soviet
## default is $BUILD-build
SOV_DIR="build-$BUILD"
## where the pre-built files used in the 3rd script are stored
## default is soviet-files
SOV_FILES="soviet-files"
## where you want the final img files to be stored
## default is $BUILD-files
SOV_BUILD="$BUILD-files"
#############

## add a line to cccp.conf to install to the correct directory.

## gather the ROOT variable
if [[ -n "$(grep ROOT /etc/cccp.conf)" ]]; then
BUILDCHECK="$(grep 'ROOT' /etc/cccp.conf)"
    if [[ "ROOT=$SOV_DIR" != "$BUILDCHECK" ]]; then
    echo 'BUILD and BUILDCHECK do not match, replacing'
## if not, delete it and make an update
    sed -i '/ROOT/d' /etc/cccp.conf
    echo "ROOT=$SOV_DIR" >> /etc/cccp.conf
sleep 2
    fi
else
## if there's no ROOT variable, make one
echo 'adding $ROOT to /etc/cccp.conf'
echo "ROOT=$SOV_DIR" >> /etc/cccp.conf
sleep 2
fi

## make the base filesystem
if [ ! -f 01-complete ]; then
source 01-dirs.sh
fi

## use cccp to install soviet
if [ -f 01-complete ] && [ ! -f 02-complete ]; then
source 02-soviet.sh
fi

## copy relevant files to the new install
if [ -f 02-complete ] && [ ! -f 03-complete ]; then
source 03-files.sh
fi

## nspawn to enter the system and run configs
if [ -f 03-complete ] && [ ! -f 04-complete ]; then
systemd-nspawn --as-pid2 -D $SOV_DIR /04-config.sh
## create a check file in the host system
if [ -f $SOV_DIR/04-complete ]; then
touch 04-complete
rm $SOV_DIR/04-complete
 
## make the deliverables
if [ -f 04-complete ] && [ ! -f 05-complete ]; then
source 05-build.sh
fi

if [ -f 05-complete ]; then
## remove the build file so we get a fresh start next time
rm build
## remove build status files made in 02
rm build-{progress,list}
## clear out the check files
rm *-complete
## get a final time for the build
echo "SOVIET LINUX, build $BUILD\nFinished: $(date)\nTime elapsed: $($DURATION / 60)M $($DURATION % 60)S" >> build-time
fi
