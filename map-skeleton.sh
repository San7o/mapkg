#! /bin/sh

set -e

NAME=""
VERSION=""
MAPKG_DIR=""
GIT_URL=""
GIT_USERNAME=""
DEPENDENCIES=""

dependencies() {
    echo "$DEPENDENCIES"
}

download() {
    echo "Downloading $NAME $VERSION"
}

build() {
    echo "Building $NAME $VERSION"
}

install() {
    echo "Installing $NAME $VERSION"
}

clean() {
    echo "Cleaning $NAME $VERSION"
}

remove() {
    echo "Removing $NAME $VERSION"
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
