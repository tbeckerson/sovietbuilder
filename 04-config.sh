##! /bin/bash

## explode immediately if something breaks
set -e

###########
# this script is run from inside the build environment, to perform any
# customization tasks
###########

## get the build date
BUILD="$(cat /build)"
## kver for the initrd
KVER="$(ls /lib/modules/)"


## strip binaries to reduce size
#source /strip.sh
## requested by some programs
libtool --finish /usr/lib
## Set up the basic target structure:
systemctl preset-all
## create a default locale
localedef -i C -f UTF-8 C.UTF-8
## make-ca certs and update
make-ca -g
systemctl enable update-pki.timer
## look for polkitd user and group, add them if not present
id -g polkitd &>/dev/null || groupadd -fg 27  polkitd
id -u polkitd &>/dev/null || useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27  -g polkitd -s /bin/false polkitd
## establish shadowed passwords
pwconv
grpconv
## set up useradd for shadow
## is this needed with homectl??
#useradd -D --gid 999
## some progs look for mtab file
ln -sfv /proc/self/mounts /etc/mtab
## remove the unused .la files
find /usr/{lib,libexec} -name \*.la -delete
## Create the /etc/machine-id file needed by systemd-journald:
systemd-machine-id-setup
## sysext and confext perform the /var/lib/* overlay
#systemctl enable systemd-sysext
#systemctl enable systemd-confext
## one day, A/B updates
systemctl enable systemd-sysupdate
## homectl
systemctl enable systemd-homed
## OOM killer
systemctl enable systemd-oomd
## downloading more ram
#systemctl enable zramswap
## making sure the networking is correct
systemctl enable systemd-networkd
systemctl enable systemd-resolved
## dbus-broker
systemctl enable dbus-broker
## audit-rules needs actual rules
#systemctl disable audit-rules
## get the boot files
cp -v /usr/lib/systemd/boot/efi/systemd-bootx64.efi /efi/EFI/BOOT/BOOTX64.EFI
cp -v /usr/lib/systemd/boot/efi/systemd-bootx64.efi /efi/EFI/systemd/

## img and efi file for the installation img
## initrd - maybe needs --kver ${KVER//-zen1}
dracut --kver $KVER --kmoddir /lib/modules/$KVER --add livenet --add-drivers ' vfat squashfs btrfs ' --no-early-microcode --strip -I ' /usr/bin/nano ' /tmp/initrd-installation.img
## uki
ukify build --linux=/usr/lib/modules/$KVER/vmlinuz-soviet --initrd=/tmp/initrd-installation.img --uname=$KVER --cmdline=@/etc/kernel/cmdline-installer --splash=/efi/logo-soviet-boot.bmp --output=/efi/sovietlinux-$BUILD-installation.efi
## cmdline-installer file is no longer needed
rm -v /etc/kernel/cmdline-installer

## make soviet-install.sh executable
chmod +x /etc/soviet-install.sh

## all done!
touch /04-complete
