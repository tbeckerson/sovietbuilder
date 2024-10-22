
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
## make dir for efi
mkdir /mnt/efi
## target EFI partition
mount LABEL=SOVIET-EFI /mnt/efi

## copy soviet to the new partitions
echo 'installing Soviet Linux to your drive! Please be patient' 
cp -Rv /run/rootfsbase/* /mnt

## core customizations
systemd-firstboot --root=/mnt --setup-machine-id --prompt-locale --prompt-timezone --prompt-keymap --prompt-hostname --prompt-root-password --root-shell=/bin/bash --force

## start an nspawn, perform final steps 
systemd-nspawn -D /mnt --as-pid2 /etc/soviet-final.sh

## get rid of the temp scripts when done
rm /mnt/etc/soviet-final.sh
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
