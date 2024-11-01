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
# - ./mapkg.sh <install|remove|update> <package[s ...]>
#
# ======================================================

# Dependencies needed to run this script
BASE_DEPENDENCIES="make"

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
# Return: None
# Exit code: 1 if the program is not installed
assert_installed() {
	if ! command -v "$1" >/dev/null 2>&1; then
		print_error "$1 is not installed. You need to install
                     it to run this script"
		exit 1
	fi
}

# Function: check_dependencies
# Description: Check if all the dependencies are installed
# Parameters:
# - $1: The list of dependencies to check
# Return: None
# Exit code: 1 if a dependency is not installed
check_dependencies() {
	echo "$1" | tr ' ' '\n' | while read -r dep; do
		assert_installed "$dep"
	done
}

# Function: print_help
# Description: Print the help message
# Parameters: None
# Return: None
# Exit code: 0
print_help() {
	echo "Usage: $0 <install|remove|update> <package[s ...]>"
	exit 0
}

install() {
	echo "Installing $1"
	# TODO
}

remove() {
	echo "Removing $1"
	# TODO
}

update() {
	echo "Updating $1"
	# TODO
}

# Function: parse_args
# Description: Parse the arguments and execute the correct action
# Parameters:
# - $1: The action to perform
# - $2: The list of packages to install, remove or update
# Return: None
# Exit code: None
parse_args() {
	if [ $# -lt 2 ]; then
		print_help
	fi

	case $1 in
	install)
		echo "Installing $2"
		;;
	remove)
		echo "Removing $2"
		;;
	update)
		echo "Updating $2"
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
	echo "Done"
}

main "$@"
