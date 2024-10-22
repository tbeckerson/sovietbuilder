#! /bin/bash

## explode immediately if something breaks
set -e

###########
# this script checks a list of package names, and installs them
# using the cccp installer from the host system
###########

## git an updated OUR base tree
## leaving commented until we get a source that isn't in constant flux
#if [[ ! -d /var/cccp/sources/OUR ]]; then
#git clone --depth 1 -C /var/cccp/sources/ $SOVIET_SOURCE
#else
#( cd /var/cccp/sources/OUR
#git pull )
#fi

## gather the SOVIET_ROOT variable, put it in BUILDCHECK
 if [[ -n "$(grep SOVIET_ROOT /etc/cccp.conf)" ]]; then
BUILDCHECK="$(grep 'SOVIET_ROOT' /etc/cccp.conf)"
  ## see if it's the same as SOV_DIR
  if [[ "SOVIET_ROOT=$SOV_DIR" != "$BUILDCHECK" ]]; then
  ## change SOVIET_ROOT and SOVIET_SPM_DIR to match BUILDCHECK
  sed -i "s|SOVIET_ROOT=/|SOVIET_ROOT=$SOV_DIR|" /etc/cccp.conf
  sed -i "s|SOVIET_SPM_DIR=.*|SOVIET_SPM_DIR=$SOV_DIR/var/cccp/spm|" /etc/cccp.conf
  fi
fi

#########
# these need to be in place before programs are installed
# new progs might add/change content
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
