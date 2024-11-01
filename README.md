# mapkg

A Packet manager for *NIX, via a POSIX compliant `sh` shell script.

Originally created by Giovanni Santini to manage his Linux From Scratch
systems.

```
Usage: ./mapkg.sh [options] [packages]

Options:
    install <package>: Install the specified package[s]
    remove  <package>: Remove the specified package[s]
    update: Update the package list
    upgrade   <package>: Upgrade the specified package[s]
    list: List all the installed packages
    help: Print this help message
    version: Print the version of the script
```

## Installation

Clone this repo in `/opt` or specify the installation path in `MAPKG_PATH`.
You will use [mapkg.sh](./mapkg.sh) to manage your packages, 
add It's location to your path or copy it in `/usr/bin`. 
The packages will be installed in `MAPKG_PATH/bin` so you should add this
to your path aswell. That's it.

## Repository structure

All build scripts (that will be referred to as **"maps"**) are stored in a
tree structure in [maps](./maps)
with the following structure:

```
- maps
   - category
      - package
         - version
```

For example, `gcc-14.1` would be found in:
```
- maps
  - dev
    - gcc
      - 14.1.0
```

The location of the map is either specified in `MAPKG_PATH`/maps env
variable or in a default location `/opt/mapkg/maps`.

## Maps

Each map contains a makefile with the following informations 
about a specific package:

- list of dependencies
- isntallation instructions
- uninstallation instructions
- instruction to install documentation (man pages)
- metadata: description and other things

When you want to install a package, the instructions on the
map are executed and the result is saved in `MAPKG_PATH`/bin.

## Updates

Maps are updated via git by fetching this repository, either
using a known tag or from master branch.
