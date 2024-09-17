
#! /bin/bash

## parse the kernel version
KVER=$(uname -r)
## parse the os-release file for a date
## this var needs to be re-created for this script
BUILD="$(grep VERSION_ID= /etc/os-release | sed 's/VERSION_ID=//')"
cd /
## get a fresh machine-id
systemd-machine-id-setup
## use the systemd-provided keys for systemd-sysupdate
echo 'Adding gpg keys for systemd (gpg --import /lib/systemd/import-pubring.gpg)'
sleep 1
gpg --import /lib/systemd/import-pubring.gpg
## recommended to avoid disk thrashing
chattr +C /var/log/journal
## new initrd using host-only to reduce size
dracut -H -I ' /usr/bin/nano ' --add-drivers ' vfat btrfs ' --strip /tmp/sov-initrd.img
## new uki with the new initrd
/usr/lib/systemd/ukify build --linux=/usr/lib/modules/${KVER}/vmlinuz-soviet --initrd=/tmp/sov-initrd.img --uname=$KVER --splash=/efi/logo-soviet-boot.bmp --cmdline=@/etc/kernel/cmdline --output=/efi/EFI/Linux/sovietlinux-$BUILD-initrd.efi
## fresh random seed
bootctl random-seed
## not needed with flat filesystem
# mv /etc/fstab-install /etc/fstab
