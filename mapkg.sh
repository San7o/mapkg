#! /bin/sh

# ======================================================
#
# The mapkg package manager script, developed by
# Giovanni Santini to maintain the software on
# his LFS (Linux From Scratch) systems.
#
# Date: 2024-11-01
# License: GPLv3
# Version: 0.1
# Author: Giovanni Santini
#
# Dependencies:
#  - make
#
# Usage:
# - ./mapkg.sh [options] [packages]
#
# ======================================================

# Current version of the script
VERSION="0.1.0"
# Dependencies needed to run this script
BASE_DEPENDENCIES="echo basename find grep head sed xargs command cat touch"
# Default mapkg directory
MAPKG_DIR="/opt/mapkg"

# Function: print_error
# Description: Print an error message to the standard error
# Parameters:
# - $1: The error message to print
# Return: None
print_error() {
	echo "Error: $1" >&2
}

# Function: assert_installed
# Description: Check if a program is installed
#           and accessible via the PATH
# Parameters:
# - $1: The program to check
# Return: true if the program is installed, false otherwise
is_installed() {
	if ! command -v "$1" >/dev/null 2>&1; then
		return 1
	fi
	return 0
}

# Function: check_dependencies
# Description: Check if all the dependencies are installed
# Parameters:
# - $1: The list of dependencies to check
# Return: None
# Exit code: 1 if a dependency is not installed
check_dependencies() {
	echo "$1" | tr ' ' '\n' | while read -r dep; do
		if ! is_installed "$dep"; then
			print_error "$dep is not installed. Please install it before running this script."
			exit 1
		fi
	done
}

# Function: set_mapkg_dir
# Description: Updates the mapkg directory if the
#       MAPKG_PATH variable is set
# Parameters: None
# Return: None
# Exit code: None
update_mapkg_dir() {
	if [ -n "$MAPKG_PATH" ]; then
		MAPKG_DIR="$MAPKG_PATH"
	fi
}

# Function: assert_mapkg_dir
# Description: Check if the mapkg directory exists
# Parameters: None
# Return: None
# Exit code: 1 if the mapkg directory does not exist
assert_mapkg_dir() {
	update_mapkg_dir
	if [ ! -d "$MAPKG_DIR" ]; then
		print_error "The mapkg directory $MAPKG_DIR does not exist. Please create it or set MAPKG_PATH correctly before running this script."
		exit 1
	fi
}

# Function: search
# Description: Search for a package map
# Parameters:
# - $1: The package to search
# Return: None
# Exit code: 1 if the package is not found
search() {
	if [ -z "$1" ]; then
		print_error "No package specified"
		exit 1
	fi

	assert_mapkg_dir
	echo "Searching for $1"

	map_dirs="$(find "$MAPKG_DIR" -type d -name "*$1*")"
	if [ -z "$map_dirs" ]; then
		print_error "The map for $1 was not found in $MAPKG_DIR"
		exit 1
	fi

	# Print the found maps

	echo "Found maps:"
	echo "$map_dirs" | tr ' ' '\n' | while read -r map_dir; do
		version_dirs=$(find "$map_dir" -type d -not -path "$map_dir")
		versions=$(echo "$version_dirs" | xargs -n 1 basename | tr '\n' ' ' | sed 's/ $//')
		echo " - $(basename "$map_dir"): $versions"
	done
}

# Function: is_package_installed
# Description: Check if a package is installed
# Parameters:
# - $1: The package to check
# Return: 1 if the package is installed, 0 otherwise
is_package_installed() {
	assert_mapkg_dir

	if [ ! -f "$MAPKG_DIR/installed" ]; then
		touch "$MAPKG_DIR/installed"
	fi

	if ! grep -q "$1" "$MAPKG_DIR/installed"; then
		return 1
	fi
	return 0
}

# Function: install
# Description: Install a package
# Parameters:
# - $1: The package to install
# - $2: The optional version of the package to install
# Return: None
# Exit code: 1 if the package is not found or the build fails
install() {
	if [ -z "$1" ]; then
		print_error "No package specified"
		exit 1
	fi

	assert_mapkg_dir

	if is_package_installed "$1"; then
		print_error "The package $1 is already installed"
		exit 1
	fi

	echo "Installing: $1"

	map_dir="$(find "$MAPKG_DIR" -type d -name "$1")"
	if [ -z "$map_dir" ]; then
		print_error "The map for $1 was not found in $MAPKG_DIR Maybe you need to update?"
		exit 1
	fi
	if [ -n "$2" ]; then # Version specified
		map_dir="$(find "$map_dir" -type d -name "$2")"
		if [ -z "$map_dir" ]; then
			print_error "The map for $1 with version $2 was not found in $MAPKG_DIR"
			exit 1
		fi
	else
		# Get the latest version (biggest number)
		map_dir="$(find "$map_dir" -type d -not -path "$map_dir" | head -n 1)"
	fi

	echo "Found map in $map_dir"

	if [ ! -f "$map_dir/map.sh" ]; then
		print_error "The build script for $1 was not found in $map_dir"
		exit 1
	fi

	# Run the download script
	"$map_dir/map.sh" download

	# Run the build script
	"$map_dir/map.sh" build

	# Run the install script
	"$map_dir/map.sh" install

	# Save the installed package
	echo "$1 $(basename "$map_dir")" >>"$MAPKG_DIR/installed"
}

remove() {
	assert_mapkg_dir
	echo "Removing $1"
	# TODO
}

update() {
	assert_mapkg_dir
	echo "Updating"
	# TODO: Pull from git
	# TODO: Set all maps as executable
}

upgrade() {
	assert_mapkg_dir
	echo "Upgrading $1"
	# TODO
}

# Function: list
# Description: List all the installed packages
list() {
	assert_mapkg_dir
	echo "Installed packages:"
	cat "$MAPKG_DIR/installed"
}

# Function: print_version
# Description: Print the version of the script
# Parameters: None
# Return: None
# Exit code: 0
print_version() {
	echo "mapkg $VERSION"
	exit 0
}

# Function: print_help
# Description: Print the help message
# Parameters: None
# Return: None
# Exit code: 0
print_help() {
	echo "Usage: $0 [options] [packages]"
	printf "\n"
	echo "Options:"
	echo "    install <package> <version>: Install the specified package[s]"
	echo "    search  <package>: Search if a package map exists"
	echo "    remove  <package>: Remove the specified package[s]"
	echo "    upgrade <package>: Upgrade the specified package[s]"
	echo "    update: Update the package list"
	echo "    list: List all the installed packages"
	echo "    help: Print this help message"
	echo "    version: Print the version of the script"
	exit 0
}

# Function: parse_args
# Description: Parse the arguments and execute the correct action
# Parameters:
# - $1: The action to perform
# - $2: The list of packages to install, remove or update
# Return: None
# Exit code: None
parse_args() {
	case $1 in
	search)
		search "$2"
		;;
	install)
		install "$2" "$3"
		;;
	remove)
		remove "$2"
		;;
	update)
		update
		;;
	upgrade)
		upgrade "$2"
		;;
	list)
		list
		;;
	version)
		print_version
		;;
	*)
		print_help
		;;
	esac
}

# Main function
main() {
	check_dependencies "$BASE_DEPENDENCIES"
	parse_args "$@"
}

main "$@"
