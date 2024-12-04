#! /bin/sh

VERSION="1.86.0"
MAPKG_DIR="/opt/mapkg"
GIT_URL="github.com"
GIT_USERNAME="boostorg"
NAME="boost"
DEPENDENCIES="tar which"

dependencies() {
        echo "$DEPENDENCIES"
}

download() {
        echo "Downloading $NAME-$VERSION..."

        if [ -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz ]; then
                echo "Package already downloaded"
                exit 0
        fi

        URL="https://$GIT_URL/$GIT_USERNAME/$NAME/releases/download/$NAME-$VERSION/$NAME-$VERSION-b2-nodocs.tar.gz"
	PATCH_URL="https://www.linuxfromscratch.org/patches/blfs/12.2/boost-1.86.0-upstream_fixes-1.patch"

        if [ ! -d "$MAPKG_DIR"/build ]; then
                mkdir "$MAPKG_DIR"/build
        fi
        if command -v wget >/dev/null 2>&1; then
                wget -q -O "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz "$URL"
		wget -q -O "$MAPKG_DIR"/build/boost-1.86.0-upstream_fixes-1.patch "$PATCH_URL"
          elif command -v curl >/dev/null 2>&1; then
                curl -s -L -o "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz "$URL"
		wget -s -L -o "$MAPKG_DIR"/build/boost-1.86.0-upstream_fixes-1.patch "$PATCH_URL"
        elif command -v fetch >/dev/null 2>&1; then # BSD
                fetch -q -o "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz "$URL"
		fetch -q -o "$MAPKG_DIR"/build/boost-1.86.0-upstream_fixes-1.patch "$PATCH_URL"
        else
                echo "Error: either curl, wget or fetch is required to download files" >&2
                exit 1
        fi
        echo "Downloaded $NAME-$VERSION to $MAPKG_DIR/build/$NAME-$VERSION.tar.gz"
}

build() {
        echo "Building..."
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

	patch -Np1 -i ../boost-1.86.0-upstream_fixes-1.patch
	case $(uname -m) in
	    i?86)
		sed -e "s/defined(__MINGW32__)/& || defined(__i386__)/" \
		    -i ./libs/stacktrace/src/exception_headers.h ;;
	esac

	./bootstrap.sh --prefix=/$MAPKG_DIR --with-python=python3
	./b2 stage -j$(nproc) threading=multi link=shared
	
        echo "Done building"
}

install() {
        echo "Installing..."
        if [ ! -d "$MAPKG_DIR"/build ]; then
                echo "Error: build directory does not exist" >&2
                exit 1
        fi
        if [ ! -d "$MAPKG_DIR"/bin ]; then
                mkdir "$MAPKG_DIR"/bin
        fi
	if [ ! -d "$MAPKG_DIR"/build/"$NAME"-"$VERSION" ]; then
                echo "Error: project directory does not exist" >&2
                exit 1
	fi
        cd "$MAPKG_DIR"/build/"$NAME"-"$VERSION" || return 1
	./b2 install threading=multi link=shared
}

clean() {
        echo "Cleaning..."
        rm -rf "$MAPKG_DIR"/build/"$NAME"-"$VERSION"
        rm -f "$MAPKG_DIR"/build/"$NAME"-"$VERSION".tar.gz
	rm -f "$MAPKG_DIR"/build/boost-1.86.0-upstream_fixes-1.patch
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
