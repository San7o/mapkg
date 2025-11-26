#! /bin/sh

#
# Fastfetch
# =========
#

set -e

VERSION="2.27.1"
MAPKG_DIR="$HOME/mapkg"
GIT_URL="github.com"
GIT_USERNAME="fastfetch-cli"
NAME="fastfetch"
DEPENDENCIES=""

dependencies() {
    echo "$DEPENDENCIES"
}

download() {
    echo "Downloading $NAME $VERSION"

    if [ -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz ]; then
        echo "Package already downloaded"
        exit 0
    fi

    URL="https://$GIT_URL/$GIT_USERNAME/$NAME/archive/refs/tags/$VERSION.tar.gz"

    if [ ! -d "$MAPKG_DIR"/build ]; then
        mkdir "$MAPKG_DIR"/build
    fi
    if command -v wget >/dev/null 2>&1; then
	      echo "Downloading with wget"
        wget -q -O "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz "$URL"
    elif command -v curl >/dev/null 2>&1; then
	      echo "Downloading with curl"
        curl -o "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz "$URL"
    elif command -v fetch >/dev/null 2>&1; then # BSD
	      echo "Downloading with fetch"
        fetch -q -o "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz "$URL"
    else
        echo "Error: either curl, wget or fetch is required to download files" >&2
        exit 1
    fi
    
    echo "Downloaded $NAME-$VERSION to $MAPKG_DIR/build/$NAME-$VERSION.tar.gz"
}

build() {
    echo "Building $NAME $VERSION"
    
    if [ ! -d "$MAPKG_DIR"/build ]; then
        echo "Error: build directory does not exist" >&2
        exit 1
    fi
    if [ ! -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz ]; then
        echo "Error: $NAME-$VERSION.tar.gz does not exist" >&2
        exit 1
    fi
    tar -xf "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz -C "$MAPKG_DIR"/build
    cd "$MAPKG_DIR"/build/"$NAME"-"$VERSION" || return 1
    mkdir -p build
    cd build || return 1
    cmake ..
    cmake --build . --target fastfetch -j "$(nproc)"
}

install() {
    echo "Installing $NAME $VERSION"
    
    if [ ! -d "$MAPKG_DIR"/build ]; then
        echo "Error: build directory does not exist" >&2
        exit 1
    fi
    if [ ! -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION"/build/"$NAME" ]; then
        echo "Error: $NAME does not exist" >&2
        exit 1
    fi
    if [ ! -d "$MAPKG_DIR"/bin ]; then
        mkdir "$MAPKG_DIR"/bin
    fi
    cp "$MAPKG_DIR"/build/"$NAME"-"$VERSION"/build/"$NAME" "$MAPKG_DIR"/bin/"$NAME"
}

clean() {
    echo "Cleaning $NAME $VERSION"
    
    rm -rf "$MAPKG_DIR"/build/"$NAME"-"$VERSION"
    rm -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz
}

remove() {
    echo "Removing $NAME $VERSION"
    
    if [ ! -f "$MAPKG_DIR"/bin/"$NAME" ]; then
        echo "Error: $NAME is not installed" >&2
        exit 1
    fi
    rm -rf "$MAPKG_DIR"/bin/"$NAME"
}

main() {
    if [ -z "$1" ]; then
        echo "No command specified" >&2
        exit 1
    fi

    if [ -z "$1" ]; then
        echo "No path specified" >&2
        exit 1
    fi
    MAPKG_DIR="$2"

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

main "$@"
