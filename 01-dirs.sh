#! /bin/bash

## explode immediately if something breaks
set -e

###########
# the minimum filesystem
###########

## make this dir if it's not already there
mkdir -pv $SOV_DIR
## base directories without subdirectories
mkdir -pv $SOV_DIR/{mnt,opt}
## base directories with subs (efi, etc, usr and var)
mkdir -pv $SOV_DIR/efi/{loader,EFI/{BOOT,Linux,systemd}}
mkdir -pv $SOV_DIR/etc/{kernel,pam.d,systemd/{network,system,system-preset},sysupdate.d,udev/rules.d}
mkdir -pv $SOV_DIR/usr/{bin,etc,include,lib,libexec,local,share,src}
mkdir -pv $SOV_DIR/var/{cache,lib/{confexts,extensions},local,log,mail,opt,spool,tmp}
## links for /
ln -sv usr/bin $SOV_DIR/bin
ln -sv usr/bin $SOV_DIR/sbin
ln -sv usr/lib $SOV_DIR/lib
ln -sv usr/lib $SOV_DIR/lib64

## links for /usr
ln -sv lib $SOV_DIR/usr/lib64
ln -sv bin $SOV_DIR/usr/sbin

## links for /var
#( cd $SOV_DIR/var &&
#ln -sv /run/lock lock
#ln -sv /run run )

## fix perms
#chmod 0750 $SOV_DIR/root
#chmod 1777 $SOV_DIR/tmp $SOV_DIR/var/tmp
#chmod 1777 $SOV_DIR/var/tmp
#chmod 0555 $SOV_DIR/{dev,proc,run,sys}

## all done!
touch 01-complete
