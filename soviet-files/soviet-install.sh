
#! /bin/bash

## stop immediately if something doesn't work
set -e

## figure out how to identify a target, or get user to input it
## and use $1 to pass it to $TARGET
TARGET="$1"

## partition the target drive
sgdisk -n 1:0:+512M -c 1:"SOVIET-EFI" -t 1:ef00 -n 2:0:0 -c 2:"sovietlinux" -t 2:8304 $TARGET

## format the new partitions
mkfs.vfat ${TARGET}1 -F 32 -n SOVIET-EFI
mkfs.btrfs ${TARGET}2 -L sovietlinux
## mount target root
mount LABEL=sovietlinux -o compress=zstd:3 /mnt
## target EFI partition
mount LABEL=SOVIET-EFI /mnt/efi

## copy soviet to the new partitions
echo 'installing Soviet Linux to your drive! Please be patient' 
cp -Rv /run/rootfsbase/* /mnt

## core customizations
systemd-firstboot --root=/mnt --setup-machine-id --prompt-locale --prompt-timezone --prompt-keymap --prompt-hostname --prompt-root-password --root-shell=/bin/bash --force

## inject the final steps in this script
cat > /mnt/soviet-final.sh << "EOF"
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
## systemd recommends this to avoid disk thrashing
chattr +C /var/log/journal
## new initrd using host-only to reduce size
dracut -H -I ' /usr/bin/nano ' --add-drivers ' vfat btrfs ' --strip /tmp/sov-initrd.img
## new uki with the new initrd
/usr/lib/systemd/ukify build --linux=/usr/lib/modules/${KVER}/vmlinuz-soviet --initrd=/tmp/sov-initrd.img --uname=$KVER --splash=/efi/logo-soviet-boot.bmp --cmdline=@/etc/kernel/cmdline --output=/efi/EFI/Linux/sovietlinux-$BUILD-initrd.efi
## fresh random seed
bootctl random-seed
mv /etc/fstab-install /etc/fstab
EOF
chmod +x /mnt/soviet-final.sh

## start an nspawn, run the above script
systemd-nspawn -D /mnt --as-pid2 /soviet-final.sh

## get rid of the temp scripts when done
rm /mnt/soviet-final.sh
rm /mnt/etc/soviet-install.sh
## all done!
while true; do

read -p "Installation complete! Do you want to reboot, poweroff, or quit to shell? (r/p/q) " rpq
case $rpq in 
	[rR] ) echo rebooting!;
		systemctl reboot;;
	[pP] ) echo shutting down!;
		systemctl poweroff;;
	[qQ] ) echo quitting to prompt;

		exit;;
	* ) echo invalid response;;
esac
done
