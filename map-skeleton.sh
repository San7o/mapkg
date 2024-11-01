#! /bin/sh

download() {
        echo "Downloading..."
}

build() {
        echo "Building..."
}

install() {
        echo "Installing..."
}

remove() {
        echo "Removing..."
}

main() {
        case $1 in
                "download")
                        download
                        ;;
                "build")
                        build
                        ;;
                "install")
                        install
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
