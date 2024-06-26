## sovietbuilder
script to generate a soviet linux build
---

**SUMMARY**  
This build script uses a host machine to create a new _soviet_ build on a target machine. It could work on any Linux distro with the normal suite of compiling tools (gcc, automake, meson, cmake, etc), if you also install the _cccp_ package manager.  

_Soviet Linux_ can be used to build itself, and any one of the recent (2024 onwards) _sovietlinux-*-core.tar.gz_ builds can be used. When in doubt, use the most recent. 

These scripts are designed to be simple to understand, and easy to modify if you want to make your own custom _soviet_ build.

**INSTRUCTIONS**
(optional) edit the host's /etc/cccp.conf file to add compiler flags.
The _soviet_ development builds use this:
```
MAKE_FLAGS="-jx"
CFLAGS="-march=x86_64-v2 -mtune=generic -O2 -pipe -fno-plt -fexceptions -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -fstack-clash-protection -fcf-protection"  
CXXFLAGS="$CFLAGS -Wp,-D_GLIBCXX_ASSERTIONS"
LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"
LTOFLAGS="-flto=auto"
```
The `-jx` flag should be changed to a suitable number for your system.

You can use whatever flags you want, but the above is known to work for almost all programs. You add more at your own risk. For a build that you _only_ intend to use on your own system, changing `-march=x86_64-v2` to `-march=native` is a recommend option.

1. edit the _sovietbuilder.sh_ file:
There are three variables starting at appx line 30, that point to directories. The default options use $PWD (present working directory), and will create folders in the same directory that you run the script from. These three variables should be the only things you need to change in the script.

2. if you're installing to a partition or other mounted location, make sure you create the necessary folders (that you named in the _sovietbuilder.sh_ file, as above) and mount your targets. If you're not mounting anything, the script will create these folders for you. Note that the _soviet_ build generated in this script will take up about 2.5G of space, so plan accordingly.

3. run the _sovietbuilder.sh_ script. This will probably take several hours, depending on your machine. Some programs (the kernel for example) will require user intervention.

**LAYOUT**  
The _sovietbuilder.sh_ script calls 5 other scripts to create the _soviet_ build:
- **01-dirs.sh** creates a directory tree in the target location.
- **02-soviet.sh** runs the _cccp_ package installer on the host system, and compiles everything the *build_list* file. This is intended to be every program included in the _soviet_ build.
- **03-files.sh** copies pre-made configuration files from the $SOV_FILES directory into the target system.
- **04-config.sh** uses systemd-nspawn to enter the target system, and runs a variety of configuration tasks.
- **05-build.sh** creates the standard _soviet_ deployment files - a *core.tar.gz* file, and a *installation.img* file.
