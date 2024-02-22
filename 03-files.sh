#! /bin/bash

## explode immediately if something breaks
set -e

############
# this script copies any pre-made files to the build.
# some sed lines will customize the files to this specific build
############

## profile and logo
cp -v $SOV_FILES/profile $SOV_DIR/root/.bash_profile
cp -v $SOV_FILES/logo-soviet-boot.bmp $SOV_DIR/efi
## for systemd-networkd
cp -v $SOV_FILES/10-dhcp.network 20-wifi.network $SOV_DIR/etc/systemd/network/
## systemd install creates this, is a non-working template
rm -v $LFS_BUILD_DIR/etc/systemd/network/10-eth-static.network
## this defaults to using vendor services
cp -v $SOV_FILES/networkd.conf $SOV_DIR/etc/systemd/
## drop the LFS supplied version and let systemd do the work
rm -v $SOV_DIR/etc/resolv.conf
## for systemd-sysupdate
cp -v $SOV_FILES/10-usr.conf 30-efi.conf $SOV_DIR/etc/sysupdate.d/
## for the UKIs
cp -v $SOV_FILES/cmdline $SOV_FILES/cmdline-installer $SOV_DIR/etc/kernel/
# fstab-install for installer script
cp -v $SOV_FILES/fstab-install $SOV_DIR/etc/
## copy and update content of os-release
cp -v $SOV_FILES/os-release $SOV_DIR/usr/lib/
sed -i "s/xxxxxx/$BUILD/" $SOV_DIR/usr/lib/os-release
## the loader config for systemd-boot
cp -v $SOV_FILES/loader.conf $SOV_DIR/efi/loader/
echo type2 >> $SOV_DIR/efi/loader/entries.srel
## zram support
cp -v $SOV_FILES/zramswap.conf $SOV_DIR/etc/
cp -v $SOV_FILES/zramctl $SOV_DIR/etc/systemd/system/
cp -v $SOV_FILES/zramswap.service $SOV_DIR/usr/lib/systemd/system/zramswap.service
## fix problems with LFS's /etc/hosts problem by letting systemd
## manage the network
cp -v $SOV_FILES/hosts $SOV_DIR/etc

## os-release and localtime should be relative symlinks, so
## remove default files, re-link with custom work
cd $SOV_DIR/etc
rm os-release localtime
ln -s ../usr/lib/os-release
ln -s ../usr/share/zoneinfo/UTC localtime
## remove lsb-release, supplanted by os-release
rm -v $LFS_BUILD_DIR/etc/lsb-release

## systemd-boot files
cp -v $SOV_DIR/usr/lib/systemd/boot/efi/systemd-bootx64.efi $SOV_DIR/efi/EFI/BOOT/BOOTX64.EFI
cp -v $SOV_BUILD_DIR/usr/lib/systemd/boot/efi/systemd-bootx64.efi $SOV_DIR/efi/EFI/systemd/
## add some missing files that stop nscd from working
echo -e "f /run/nscd/nscd.pid 0755 root root\nf /run/nscd/service 0755 root root" >> $SOV_DIR/usr/lib/tmpfiles.d/nscd.conf
touch $SOV_DIR/etc/netgroup

## get stage 4 ready
cp $PWD/04-config.sh $SOV_DIR/
cp $PWD/build $SOV_DIR/

## all done!
touch ${PWD}/03-complete
