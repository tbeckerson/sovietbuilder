#! /bin/bash

## explode immediately if something breaks
set -e

############
# this script copies any pre-made files to the build.
# some sed lines will customize the files to this specific build
############

## profile and logo
cp -v $SOV_FILES/bash_profile $SOV_DIR/root/.bash_profile
cp -v $SOV_FILES/logo-soviet-boot.bmp $SOV_DIR/efi
## for systemd-networkd
cp -v $SOV_FILES/10-dhcp.network $SOV_FILES/20-wifi.network $SOV_DIR/etc/systemd/network/
## systemd install creates this, is a non-working template
rm -vf $LFS_BUILD_DIR/etc/systemd/network/10-eth-static.network
## this defaults to using vendor services
cp -v $SOV_FILES/networkd.conf $SOV_DIR/etc/systemd/
## drop the LFS supplied version and let systemd do the work
rm -vf $SOV_DIR/etc/resolv.conf
## fix problems with LFS's /etc/hosts problem by letting systemd
## manage the network
cp -v $SOV_FILES/hosts $SOV_DIR/etc/
## for systemd-sysupdate
cp -v $SOV_FILES/10-usr.conf $SOV_FILES/30-efi.conf $SOV_DIR/etc/sysupdate.d/
## for the UKIs
cp -v $SOV_FILES/cmdline $SOV_FILES/cmdline-installer $SOV_DIR/etc/kernel/
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
## fstab
cp -v $SOV_FILES/fstab-install $SOV_DIR/etc/
## passwd
cp -v $SOV_FILES/passwd $SOV_DIR/etc
## pam
cp -v $SOV_FILES/system-{account,auth,password,session} /etc/pam.d/
cp -v $SOV_FILES/other /etc/pam.d/

## os-release and localtime should be relative symlinks, so
## remove default files, re-link with custom work
(cd $SOV_DIR/etc
rm -f os-release localtime
ln -s ../usr/lib/os-release
ln -s ../usr/share/zoneinfo/UTC localtime
## remove lsb-release, supplanted by os-release
rm -vf $LFS_BUILD_DIR/etc/lsb-release
)

## installer script
cp -v $SOV_FILES/soviet_install.sh $SOV_DIR/etc/

## get stage 4 ready
cp 04-config.sh $SOV_DIR/
chmod 775 $SOV_DIR/04-config.sh
cp build $SOV_DIR/

## all done!
touch 03-complete
