## sovietbuilder
script to generate a soviet linux build
---

**SUMMARY**  
This build script uses a host machine to create a new soviet build on a target machine. It could work on any Linux distro with the normal suite of compiling tools (gcc, automake, meson, cmake, etc), if you also install the *cccp* and *libspm* package management tools.  

*Soviet Linux* can be used to build itself, and any one of the recent (2024 onwards) *sovietlinux-\*-core.tar.gz* builds can be used. When in doubt, use the most recent. 

These scripts are designed to be simple to understand, and easy to modify if you want to make your own custom soviet build.

**INSTRUCTIONS**  
It's recommended to review the **cccp.conf** file from the *soviet-files* directory and copy the contents to the host system's `/etc/cccp.conf` file. Edit the `MAKEFLAGS` and `NINJAJOBS` variables to something useful for your system. These numbers represent the number of cpu cores being used to compile. More cores, reduced build time.  
If you're building _only_ for your own system, switching `-march=x86-64-v2` to `-march=native` is a good idea.


1. edit the *sovietbuilder.sh* file:  
There are three variables starting at appx line 20, that point to directories. The default options use $PWD (present working directory), and will create folders in the same directory that you run the script from. These three variables should be the only things you need to change in the script.

2. if you're installing to a partition or other mounted location, make sure you create the necessary folders (that you named in the `sovietbuilder.sh` file, as above) and mount your targets. If you're not mounting anything, the script will create these folders for you. Note that the _soviet_ build generated in this script will take up about 2.5G of space, so plan accordingly.

3. run the `sovietbuilder.sh` script. This will probably take several hours, depending on your machine.

4. The build will use a generic, *everything included* kernel config that will take a _long_ time to build. If you have a custom file, add a line in cccp.conf, `LINUX_CONFIG=/path/to/config/file`.

**LAYOUT**    
```
sovietbuilder
|
|_ soviet-build
  |_ rebuilder.sh
|_ soviet-files
  |_ (many exciting files)
|_ README.md
|_ 01-dirs.sh
|_ 02-soviet.sh
|_ 03-files.sh
|_ 04-config.sh
|_ 05-final.sh
|_ sovietbuilder.sh

```
The `sovietbuilder.sh` script calls 5 other scripts to create the _soviet_ build:  
- **01-dirs.sh** creates a directory tree in the target location.  
- **02-soviet.sh** runs the cccp package installer on the host system, and compiles everything the *prog-list* file. This is intended to be every program included in the base soviet build. This will take a long time to run (probably hours).  
- **03-files.sh** copies pre-made configuration files from the $SOV_FILES directory into the target system.  
- **04-config.sh** uses systemd-nspawn to enter the target system, and runs a variety of configuration tasks.  
- **05-build.sh** creates the standard soviet deployment files - a *sovietlinux-\*-core.tar.xz* file, and a *sovietlinux-\*-installation.img* file. It also creates a *usr-\*-tar.xz* that might get used for an immutable system.     
- **rebuilder.sh** is used after the main script has completed. If you later alter your build (by chrooting or nspawning into your new build dir and making changes), the *rebuilder.sh* script will repeat the steps in 05-build.sh to create new deployment files.

## TO DO:
- ~~installer does not work!~~  
- installer sucks tho    
- strip.sh crashes during use.  
- strip.sh should parse lib numbers instead of manually changing them.  
- needs some more checks, epecially in 03 and 05, to not overwrite files or crash because a file already exists or has been deleted.  
- the build time tracker gives a 'bad substitution' error at the very end.  
- there's probably a more efficient way to loop through *prog-list* in 02?  
- some of the 03 files might not actually be necessary. Some are possibly overwriting program files from 02.    
- there's inconsistent conditionals through the scripts - some ||, some &&, some `[ if -* ]`. Needs to be standardized. Also inconsistent linking. 
- fix the readme to actually list the files in the *soviet-files* dir.
- *rebuilder* functions properly, but needs a lot of work.
- ?? probably a thousand more things.