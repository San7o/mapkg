#! /bin/sh

VERSION="9.0.2"
MAPKG_DIR="/opt/mapkg"
NAME="qemu"
DEPENDENCIES="tar glib pixaman alsa-lib dlc libslirp sdl2"
URL="https://download.qemu.org/$NAME-$VERSION.tar.xz"

dependencies() {
        echo "$DEPENDENCIES"
}

download() {
        echo "Downloading $NAME-$VERSION..."

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
        echo "Downloaded $NAME-$VERSION to $MAPKG_DIR/build/$NAME-$VERSION.tar.xz"
}

build() {
        echo "Building..."
        if [ ! -d "$MAPKG_DIR"/build ]; then
                echo "Error: build directory does not exist" >&2
                exit 1
        fi
        if [ ! -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz ]; then
                echo "Error: $NAME-$VERSION.tar.xz does not exist" >&2
                exit 1
        fi

        tar -xf "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz -C "$MAPKG_DIR"/build
        cd "$MAPKG_DIR"/build/"$NAME"-"$VERSION" || return 1

	if [ $(uname -m) = i686 ]; then
	    QEMU_ARCH=i386-softmmu
	else
	    QEMU_ARCH=x86_64-softmmu
	fi

	mkdir -vp build
	cd build

	../configure --prefix=$MAPKG_DIR         \
                     --sysconfdir=/etc           \
		     --localstatedir=/var        \
	             --target-list=$QEMU_ARCH    \
		     --audio-drv-list=alsa       \
		     --disable-pa                \
		     --enable-slirp              \
		     --docdir=/usr/share/doc/qemu-9.0.2
        unset QEMU_ARCH
	make -j$(nproc)
	
	echo "Done building"
}

install() {
        echo "Installing..."
        if [ ! -d "$MAPKG_DIR"/build ]; then
                echo "Error: build directory does not exist" >&2
                exit 1
        fi
        if [ ! -d "$MAPKG_DIR"/build/"$NAME"-"$VERSION"/build ]; then
                echo "Error: $NAME does not exist" >&2
                exit 1
        fi

        cd "$MAPKG_DIR"/build/"$NAME"-"$VERSION"/build || return 1

	make install

	if [ -f /usr/libexec/quemu-bridge-helper ]; then
	    chgrp kvm  /usr/libexec/qemu-bridge-helper
	    chmod 4750 /usr/libexec/qemu-bridge-helper
	fi

	echo "$NAME succesfully installed. Some actions are required from the user
              for additional functionalities."
	echo " - If you want users other that root to run qemu you need to add them
                 to the kvm group:"
	echo "        usermod -a -G kvm <username>"
}

clean() {
        echo "Cleaning..."
        rm -rf "$MAPKG_DIR"/build/"$NAME"-"$VERSION"
        rm -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.xz
}

remove() {
        echo "Removing..."
        if [ ! -f "$MAPKG_DIR"/build/"$NAME" ]; then
                echo "Error: $NAME is not installed" >&2
                exit 1
        fi
        rm -rf "{$MAPKG_DIR:?}/bin/$NAME"
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
