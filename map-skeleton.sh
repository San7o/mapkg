#! /bin/sh

set -e

VERSION=""
MAPKG_DIR=""
GIT_URL=""
GIT_USERNAME=""
NAME=""
DEPENDENCIES=""

dependencies() {
        echo "Dependencies: ..."
}

download() {
        echo "Downloading..."
}

build() {
        echo "Building..."
}

install() {
        echo "Installing..."
}

clean() {
        echo "Cleaning..."
}

remove() {
        echo "Removing..."
}

main() {
        case $1 in
                "dependencies")
                        dependencies
                        ;;
                "download")
                        download
                        ;;
                "build")
                        build
                        ;;
                "install")
                        install
                        ;;
                "clean")
                        clean
                        ;;
                "remove")
                        remove
                        ;;
                *)
                        echo "Command not recognized" >&2
                        ;;
        esac
}

main $@
