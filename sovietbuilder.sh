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
## default is ${PWD}/build-$BUILD
SOV_DIR="${PWD}/build-$BUILD"
## where the pre-built files used in the 3rd script are stored
## default is ${PWD}/soviet-files
SOV_FILES="${PWD}/soviet-files"
## where you want the final img files to be stored
## default is ${PWD}/$BUILD-files
SOV_BUILD="{PWD}/$BUILD-files"
#############

## add a line to cccp.conf to install to the correct directory.

## gather the SOVIET_ROOT variable
 if [[ -n "$(grep SOVIET_ROOT /etc/cccp.conf)" ]]; then
BUILDCHECK="$(grep 'SOVIET_ROOT' /etc/cccp.conf)"
if [[ "SOVIET_ROOT=$SOV_DIR" != "$BUILDCHECK" ]]; then
 echo 'BUILD and BUILDCHECK do not match, replacing'
## delete it AND SOVIET_SPM_DIR and make an update
sed -i '/SOVIET_ROOT/d' /etc/cccp.conf
sed -i '/SOVIET_SPM_DIR/d' /etc/cccp.conf
echo "SOVIET_ROOT=$SOV_DIR" >> /etc/cccp.conf
echo "SOVIET_SPM_DIR=$SOV_DIR/var/cccp/spm" >> /etc/cccp.conf
sleep 2
fi

else
## if there's no SOVIET_ROOT variable, make one
echo 'adding $SOVIET_ROOT to /etc/cccp.conf'
echo "SOVIET_ROOT=$SOV_DIR" >> /etc/cccp.conf
echo "SOVIET_ROOT=$SOV_DIR/var/cccp/spm" >> /etc/cccp.conf
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
systemd-nspawn -D $SOV_DIR /04-config.sh
fi
## create a check file in the host system
if [ -f $SOV_DIR/04-complete ]; then
touch 04-complete
rm $SOV_DIR/04-complete
 fi
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
