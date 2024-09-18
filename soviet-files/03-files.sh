#! /bin/bash

## explode immediately if something breaks
set -e

############
# this script copies any pre-made files to the build.
# some sed lines will customize the files to this specific build
############

## profile
#cp -v $SOV_FILES/bash_profile $SOV_DIR/root/.bash_profile

########
# systemd
########
## for systemd-networkd
cp -v $SOV_FILES/10-dhcp.network $SOV_FILES/20-wifi.network $SOV_DIR/etc/systemd/network/
## default to using vendor services
cp -v $SOV_FILES/networkd.conf $SOV_DIR/etc/systemd/
## drop the LFS supplied version and let systemd do the work
rm -vf $SOV_DIR/etc/resolv.conf
## let systemd manage the network
cp -v $SOV_FILES/hosts $SOV_DIR/etc/
## for systemd-sysupdate
cp -v $SOV_FILES/10-usr.conf $SOV_FILES/30-efi.conf $SOV_DIR/etc/sysupdate.d/
## presets for installed unit files
cp -v $SOV_FILES/soviet.preset $SOV_DIR/etc/systemd/system-preset/

## for the UKIs
cp -v $SOV_FILES/cmdline $SOV_FILES/cmdline-installer $SOV_DIR/etc/kernel/
## the loader config for systemd-boot
cp -v $SOV_FILES/loader.conf $SOV_DIR/efi/loader/
echo type2 >> $SOV_DIR/efi/loader/entries.srel
## logo for boot :)
cp -v $SOV_FILES/logo-soviet-boot.bmp $SOV_DIR/efi

## zram support
#cp -v $SOV_FILES/zramswap.conf $SOV_DIR/etc/
#cp -v $SOV_FILES/zramctl $SOV_DIR/etc/systemd/system/
#cp -v $SOV_FILES/zramswap.service $SOV_DIR/usr/lib/systemd/system/zramswap.service

## lvm
cp -v $SOV_FILES/11-dm-initramfs.rules $SOV_DIR/etc/udev/rules.d/

########
# traditional /etc files
########
## fstab - maybe not needed?
#cp -v $SOV_FILES/fstab-install $SOV_DIR/etc/
## profile
cp -v $SOV_FILES/profile $SOV_DIR/etc/
## shells
cp -v $SOV_FILES/shells $SOV_DIR/etc/
## inputrc
cp -v $SOV_FILES/inputrc $SOV_DIR/etc/
## locale default to C.UTF-8
cp -v $SOV_FILES/locale.conf $SOV_DIR/etc

## pam
cp -v $SOV_FILES/system-{account,auth,password,session,user} $SOV_DIR/etc/pam.d/
cp -v $SOV_FILES/{other,login,systemd-user} $SOV_DIR/etc/pam.d/

# p11-kit fixes
cp -v $SOV_FILES/trust-extract-compat $SOV_DIR/usr/libexec/p11-kit/trust-extract-compat

# log files
#touch /var/log/{btmp,lastlog,faillog,wtmp}
#chgrp -v utmp /var/log/lastlog
#chmod -v 664 /var/log/lastlog
#chmod -v 600 /var/log/btmp

## copy and update content of os-release
cp -v $SOV_FILES/os-release $SOV_DIR/usr/lib/
sed -i "s/xxxxxx/$BUILD/" $SOV_DIR/usr/lib/os-release
## os-release and localtime should be relative symlinks, so
## remove default files, re-link with custom work
(cd $SOV_DIR/etc
rm -f os-release localtime
ln -s ../usr/lib/os-release
ln -s ../usr/share/zoneinfo/UTC localtime
## remove lsb-release, supplanted by os-release
rm -vf lsb-release
)

## installer script
cp -v $SOV_FILES/soviet-install.sh $SOV_DIR/etc/
cp -v $SOV_FILES/soviet-final.sh $SOV_DIR/etc/

## get stage 4 ready
cp 04-config.sh  $SOV_DIR/
# this script segfaults
#cp $SOV_FILES/strip.sh $SOV_DIR/
chmod +x $SOV_DIR/04-config.sh
cp build $SOV_DIR/

# set root password
echo 'root:sovietlinux' | chpasswd -P $SOV_DIR

## all done!
touch 03-complete
