#! /bin/bash

## explode immediately if something breaks
set -e

## create the $SOV_BUILD dir if it's not already there
mkdir -p $SOV_BUILD

###########
# make the build unique
###########

## remove the generic efi from stage 02 out of the build
## (it never gets used)
rm -v $SOV_DIR/efi/EFI/Linux/sovietlinux-*
## move the dracut imgs and the installer efi out of build
mv $SOV_DIR/efi/sovietlinux-* $SOV_BUILD

## remove the stage 04 script, the date file, and the check from the build
rm -rv $SOV_DIR/{04-config.sh,build,04-complete}
## cover your tracks
rm -rfv $SOV_DIR/root/.bash_history
## trying to cut down on space
rm -rfv $SOV_DIR/usr/share/doc/*
## probably empty, but just in case
rm -rfv $SOV_DIR/tmp/*
## systemd journals
rm -rfv $SOV_DIR/var/log/journal/[0-9]*
## machine-id file needs to be made on a per-install basis to be unique
echo uninitialized > $SOV_DIR/etc/machine-id

############
# create the deliverables
############

## squashfs img
cd $SOV_DIR
mksquashfs ./* $SOV_BUILD/squashfs.img -b 1M -noappend
## compressed files
echo 'generating tar file of core soviet build'
tar -cf $SOV_BUILD/sovietlinux-$BUILD-core.tar ./*
echo 'generating tar file of /usr dir only'
tar -cf $SOV_BUILD/usr-$BUILD.tar ./usr/*

## the rest of the script takes place in the build directory
cd $SOV_BUILD

## quicker to use xz separately from tar, because multi-threading
echo 'compressing core.tar'
xz -T0 sovietlinux-$BUILD-core.tar
echo 'compressing usr.tar'
xz -T0 usr-$BUILD.tar

############
# installer img
############
## ideal size of installation img
## jump through hoops because bash can't do floating point
## size of squashfs
SQUASH_SIZE="$(du -b squashfs.img | cut -f -1 | numfmt --to-unit=M )"
## size of efi files
EFI_SIZE="$(du -b sovietlinux-$BUILD-installation.efi | cut -f -1 | numfmt --to-unit=M )"
## add about 20M for extra files and filesystem overhead
EFI_20="$(( $EFI_SIZE + 20 ))"
## combined size
COMBINED_SIZE="$(( $SQUASH_SIZE + $EFI_20 ))"
## divide by 20 to get 5% of size
FIVE_PERCENT="$(( $COMBINED_SIZE / 20 )) "
## add 5% to allow room for fs overhead and size variance
IMG_SIZE="$(( $COMBINED_SIZE + $FIVE_PERCENT ))"
## make the img and give it a loop device
truncate -s ${IMG_SIZE}M sovietlinux-$BUILD-installation.img
## this creates the loop device, and grabs the /dev it's assigned to #
LOOP="$(losetup -fP sovietlinux-$BUILD-installation.img --show)"
## sgdisk to create partitions
echo 'creating partitions for installation img'
sgdisk -n 1:0:+"$EFI_20"M -c 1:"SOV-EFI" -t 1:ef00 -n 2:0:0 -c 2:"soviet-install" -t 2:8304 $LOOP
## make filesystems
mkfs.vfat -F 32 -n SOV-EFI ${LOOP}p1 
mkfs.ext4 -m2 -L soviet-install ${LOOP}p2 
## dirs for the partitions
mkdir -p loop-efi
mkdir -p loop-install
## mount the partitions
mount -o loop ${LOOP}p1 loop-efi/
mount -o loop ${LOOP}p2 loop-install/
## pull in the efi directory
cp -Rv $SOV_DIR/efi/* loop-efi/
## ...but not the generic efi
rm -v loop-efi/EFI/Linux/sovietlinux*.efi
## instead we want the special installer efi
cp -v sovietlinux-$BUILD-installation.efi loop-efi/EFI/Linux/
## make a home for the squashfs.img and copy it to installer
mkdir loop-install/LiveOS
cp -v squashfs.img loop-install/LiveOS/squashfs.img

## unmount and disconnect the loop device
umount loop-efi
umount loop-install
losetup -d $LOOP

## back to the main dir
cd $SOV_DIR
## all done!
touch 05-complete
