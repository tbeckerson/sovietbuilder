#! /bin/bash

## explode immediately if something breaks
set -e

###########
# this script checks a list of package names, and installs them
# using the cccp installer from the host system
###########
## git an updated OUR base tree
#if [[ ! -d /var/cccp/sources/OUR ]]; then
#git clone -C /var/cccp/sources/ https://github.com/Soviet-Linux/OUR.git
#else
#( cd /var/cccp/sources/OUR
#git pull )
#fi

## gather the SOVIET_ROOT variable
 if [[ -n "$(grep SOVIET_ROOT /etc/cccp.conf)" ]]; then
BUILDCHECK="$(grep 'SOVIET_ROOT' /etc/cccp.conf)"
if [[ "SOVIET_ROOT=$SOV_DIR" != "$BUILDCHECK" ]]; then
 echo 'BUILD and BUILDCHECK do not match, replacing'
## delete it AND SOVIET_SPM_DIR and make an update
sed -i '/SOVIET_ROOT/d' /etc/cccp.conf
sed -i '/SOVIET_SPM_DIR/d' /etc/cccp.conf
echo "SOVIET_ROOT=$SOV_DIR" >> /etc/cccp.conf
echo "SOVIET_SPM_DIR=$SOV_DIR/var/cccp/spm" >> /etc/cccp.conf
sleep 2
fi

else
## if there's no SOVIET_ROOT variable, make one
echo "SOVIET_ROOT=$SOV_DIR" >> /etc/cccp.conf
echo "SOVIET_SPM_DIR=$SOV_DIR/var/cccp/spm" >> /etc/cccp.conf
fi

#########
# these need to be in place before programs are installed
#########
for FILE in passwd group; do
if [[ ! -f $SOV_DIR/etc/$FILE ]]; then
cp -v $SOV_FILES/$FILE $SOV_DIR/etc/
fi
done

for FILE in system-account system-auth system-password system-session other; do
if [[ ! -f $SOV_DIR/etc/pam.d/$FILE ]]; then
cp -v $SOV_FILES/$FILE $SOV_DIR/etc/pam.d/
fi
done
echo 'sovietlinux' > $SOV_DIR/etc/hostname

## grab the list of programs to install
if [ ! -f prog-list ]; then
cp $SOV_FILES/prog-list .
fi
## touch some files to avoid an error
if [[ ! -f build-{progress,list} ]]; then
touch build-{progress,list}
fi
## compares full list of programs (prog-list)
## with list that's been successfully built (build-progress)
## makes a new list with programs to build (build-list)
comm --nocheck-order -3 prog-list build-progress > build-list


## loop through the todo list, build files
while read PROG; do
echo "installing $PROG"
## using the cccp package manager, install everything in the build-list
cccp --verbose -Nn -i $PROG 2>&1 | tee $SOVIET_ROOT/var/cccp/log/$PROG.log
## some programs add (but do not delete) /usr/share/info/dir
## libspm fails because of it. Check for it and delete it
if [[ -f $SOV_DIR/usr/share/info/dir ]]; then
rm $SOV_DIR/usr/share/info/dir
fi
## when the program is installed, add the name to build-progress file
if [[ -f $SOV_DIR/var/cccp/spm/OUR/$PROG.ecmp ]]; then
echo "$PROG" >> build-progress
else
echo "$PROG not listed in $SOV_DIR/var/cccp/spm - something went wrong!"
exit
fi
## finish the loop, continue with contents of build-list
done < build-list

## all done!
touch 02-complete
