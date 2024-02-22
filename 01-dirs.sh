#! /bin/bash

## explode immediately if something breaks
set -e

###########
# the minimum filesystem for a working linux install
###########

## make this dir if it's not already there
mkdir -pv $SOV_DIR
## base directories without subdirectories
mkdir -pv $SOV_DIR/{boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,srv,tmp}
## base directories with subs (usr and var)
mkdir -pv $SOV_DIR/usr/{bin,etc,games,include,lib,libexec,local,share,src}
mkdir -pv $SOV_DIR/var/{cache,lib/{confexts,extensions},local,log,mail,opt,spool,tmp}
## links for /
( cd $SOV_DIR &&
ln -sv usr/bin bin
ln -sv usr/bin sbin
ln -sv usr/lib lib64 )
## links for /usr
( cd $SOV_DIR/usr &&
ln -sv lib lib64
ln -sv bin sbin
ln -sv /var/tmp tmp )
## links for /var
( cd $SOV_DIR/var &&
ln -sv /run/lock lock
ln -sv /run run )

## all done!
touch ${PWD}/01-complete
