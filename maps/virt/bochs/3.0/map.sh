#! /bin/sh

set -e

NAME="bochs"
VERSION="3.0"
MAPKG_DIR="$HOME/mapkg"
DEPENDENCIES=
URL="https://github.com/bochs-emu/Bochs/archive/refs/tags/REL_3_0_FINAL.tar.gz"

dependencies() {
    echo "$DEPENDENCIES"
}

download() {
    echo "Downloading $NAME $VERSION..."

    if [ -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz ]; then
        echo "Package already downloaded"
        exit 0
    fi

    if [ ! -d "$MAPKG_DIR"/build ]; then
        mkdir "$MAPKG_DIR"/build
    fi
    if command -v wget >/dev/null 2>&1; then
	      echo "Downloading with wget"
        wget -q -O "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz "$URL"
    elif command -v curl >/dev/null 2>&1; then
	      echo "Downloading with curl"
        curl -o "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz "$URL"
    elif command -v fetch >/dev/null 2>&1; then # BSD
	      echo "Downloading with fetch"
        fetch -q -o "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz "$URL"
    else
        echo "Error: either curl, wget or fetch is required to download files" >&2
        exit 1
    fi
    echo "Downloaded $NAME $VERSION to $MAPKG_DIR/build/$NAME-$VERSION.tar.xz"
}

build() {
    echo "Building $NAME $VERSION"
    
    if [ ! -d "$MAPKG_DIR"/build ]; then
        echo "Error: build directory does not exist" >&2
        exit 1
    fi
    if [ ! -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz ]; then
        echo "Error: $NAME-$VERSION.tar.xz does not exist" >&2
        exit 1
    fi

    tar -xf "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz -C "$MAPKG_DIR"/build
    mv "$MAPKG_DIR"/build/Bochs-REL_3_0_FINAL "$MAPKG_DIR"/build/"$NAME"-"$VERSION" || :
    cd "$MAPKG_DIR"/build/"$NAME"-"$VERSION"/bochs || return 1

	  mkdir -vp build
	  cd build

    ../configure --prefix=$MAPKG_DIR \
                 --enable-smp \
                 --enable-cpu-level=6 \
                 --enable-all-optimizations \
                 --enable-x86-64 \
                 --enable-pci \
                 --enable-avx \
                 --enable-vmx \
                 --enable-evex \
                 --enable-debugger \
                 --enable-disasm \
                 --enable-debugger-gui \
                 --enable-logging \
                 --enable-fpu \
                 --enable-3dnow \
                 --enable-sb16=dummy \
                 --enable-cdrom \
                 --enable-x86-debugger \
                 --enable-iodebug \
                 --disable-plugins \
                 --disable-docbook \
                 --with-x --with-x11 --with-term --with-sdl2
	   make -j$(nproc)
	  
	  echo "Done building"
}

install() {
    echo "Installing $NAME $VERSION"
    if [ ! -d "$MAPKG_DIR"/build ]; then
        echo "Error: build directory does not exist" >&2
        exit 1
    fi
    if [ ! -d "$MAPKG_DIR"/build/"$NAME"-"$VERSION"/bochs/build ]; then
        echo "Error: $NAME does not exist" >&2
        exit 1
    fi

    cd "$MAPKG_DIR"/build/"$NAME"-"$VERSION"/bochs/build || return 1

    make install
}

clean() {
    echo "Cleaning $NAME $VERSION"
    rm -rf "$MAPKG_DIR"/build/"$NAME"-"$VERSION"
    rm -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz
}

remove() {
    echo "Removing $NAME $VERSION"
    rm -rf "$MAPKG_DIR"/bin/"$NAME"*
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
