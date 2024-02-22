#! /bin/bash

## explode immediately if something breaks
set -e

###########
# this script is run from inside the build environment, to perform any
# customization tasks
###########

## get the build date
BUILD="$(cat /build)";
KVER="$(ls /lib/modules/)"

## sysext and confext perform the /var/lib/* overlay
systemctl enable systemd-sysext
systemctl enable systemd-confext
## one day, A/B updates
systemctl enable systemd-sysupdate
## homectl
systemctl enable systemd-homed
## OOM killer
systemctl enable systemd-oomd
## downloading more ram
systemctl enable zramswap
## making sure the networking is correct
systemctl enable systemd-networkd
systemctl enable systemd-resolved
## dbus-broker
systemctl enable dbus-broker

## need to make img and efi file for the installation img
## initrd
dracut --kver $KVER  --add livenet --add-drivers ' vfat squashfs btrfs ' --no-early-microcode --strip -I ' /usr/bin/nano ' /efi/sovietlinux-$BUILD-initrd-installation.img
## uki
ukify build --linux=/usr/lib/modules/$KVER/vmlinuz-soviet --initrd=/efi/sovietlinux-$BUILD-initrd-installer.img --uname=$KVER --cmdline=@/etc/kernel/cmdline-installer --splash=/efi/logo-soviet-boot.bmp --output=/efi/sovietlinux-$BUILD-installation.efi
## cmdline-installer file is no longer needed
rm -v /etc/kernel/cmdline-installer

## all done!
touch /04-complete
