#! /bin/bash

## explode immediately if something breaks
set -e

## we need a build number for some customization,
## and to create unique dates for sysupdate
if [ -f build ]; then
BUILD="$(cat build)";
else
BUILD="$(date +%y%m%d%H%M)"
echo $BUILD > build
fi

##############
## The next three variables are the only ones that need to be changed.

## location of the new build of soviet
## default is ${PWD}/build-$BUILD
SOV_DIR="${PWD}/build-$BUILD"

## where the pre-built files used in the 3rd script are stored
## default is ${PWD}/soviet-files
SOV_FILES="${PWD}/soviet-files"

## where you want the final img files to be stored
## default is ${PWD}/$BUILD-files
SOV_BUILD="${PWD}/$BUILD-files"
#############

## start us off by tracking time
SECONDS=0
DURATION=$SECONDS
if [ ! -f $BUILD-build-time ]; then
echo "Started: $(date)" > $BUILD-build-time
sleep 3
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
systemd-nspawn -D $SOV_DIR /04-config.sh
fi
## create a check file in the host system
if [ -f $SOV_DIR/04-complete ]; then
touch 04-complete
 fi
## make the deliverables
if [ -f 04-complete ] && [ ! -f 05-complete ]; then
source 05-final.sh
fi

if [ -f 05-complete ]; then
## remove build files
rm -rf build*
## clear out the check files
rm *-complete
## clear target dirs from /etc/cccp.conf
sed -e '/SOVIET_ROOT/d' -e '/SOVIET_SPM_DIR/d' -i /etc/cccp.conf
## get a final time for the build
echo "SOVIET LINUX, build $BUILD, Finished: $(date), Time elapsed: ${$DURATION / 60}M ${$DURATION % 60}S" | tee -a $BUILD-build-time
fi
