## sovietbuilder
script to generate a soviet linux build
---

**SUMMARY**  
This build script uses a host machine to create a new _soviet_ build on a target machine. It could work on any Linux distro with the normal suite of compiling tools (gcc, automake, meson, cmake, etc), if you also install the _cccp_ and _libspm_ package management tools.  

_Soviet Linux_ can be used to build itself, and any one of the recent (2024 onwards) _sovietlinux-*-core.tar.gz_ builds can be used. When in doubt, use the most recent. 

These scripts are designed to be simple to understand, and easy to modify if you want to make your own custom _soviet_ build.

**INSTRUCTIONS**  
It's recommended to copy the _cccp.conf_ file from the _soviet-files_ directory to the host system's /etc directory. Edit the `MAKEFLAGS` and `NINJAJOBS` variables to something useful for your system. These numbers represent the number of cpu cores being used to compile. More cores, reduced build time.  
If you're building _only_ for your own system, switching `-march=x86-64-v2` to `-march=native` is a good idea.


1. edit the _sovietbuilder.sh_ file:
There are three variables starting at appx line 30, that point to directories. The default options use $PWD (present working directory), and will create folders in the same directory that you run the script from. These three variables should be the only things you need to change in the script.

2. if you're installing to a partition or other mounted location, make sure you create the necessary folders (that you named in the _sovietbuilder.sh_ file, as above) and mount your targets. If you're not mounting anything, the script will create these folders for you. Note that the _soviet_ build generated in this script will take up about 2.5G of space, so plan accordingly.

3. run the _sovietbuilder.sh_ script. This will probably take several hours, depending on your machine.

3a. VERY recommended to have your own kernel .config file. If not, the build will use a generic, everything included config that will take a _long_ time to build. Add a line in cccp.conf, `LINUX_CONFIG=/path/to/config/file`, and your custom config will be used automatically.

**LAYOUT**  
The _sovietbuilder.sh_ script calls 5 other scripts to create the _soviet_ build:
- **01-dirs.sh** creates a directory tree in the target location.
- **02-soviet.sh** runs the _cccp_ package installer on the host system, and compiles everything the *build_list* file. This is intended to be every program included in the base _soviet_ build. This will take a long time to run (probably hours).
- **03-files.sh** copies pre-made configuration files from the $SOV_FILES directory into the target system.
- **04-config.sh** uses systemd-nspawn to enter the target system, and runs a variety of configuration tasks.
- **05-build.sh** creates the standard _soviet_ deployment files - a *core.tar.gz* file, and a *installation.img* file.
