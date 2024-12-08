# ==============================
# Project: mapkg
# Description: Makefile for mapkg
# Author: Giovanni Santini
# Date: 2024-11-01
# License: GPLv3
# ==============================

.PHONY: check format

# ------------------------------
# Development

check:
	@echo "Checking code..."
	@find maps/ -name 'map.sh' | xargs shellcheck mapkg.sh

format:
	@echo "Formatting code..."
	@shfmt -s mapkg.sh > mapkg.sh.tmp
	@mv mapkg.sh.tmp mapkg.sh
	@chmod +x mapkg.sh

install:
	[ -f /usr/bin/mapkg ] && rm /usr/bin/mapkg || \:
	chmod +x ${PWD}/mapkg.sh
	sudo ln -s ${PWD}/mapkg.sh /usr/bin/mapkg
	sudo echo "# Begin /etc/profile.d/mapkg.sh" > /etc/profile.d/mapkg.sh
	sudo echo -e "export PATH=/opt/mapgk:/opt/mapkg/bin:\$$PATH" >> /etc/profile.d/mapkg.sh
	sudo echo -e "export PKG_CONFIG_PATH=/opt/mapgk/lib:\$$PKG_CONFIG_PATH" >> /etc/profile.d/mapkg.sh
	sudo echo -e "export GCC_INCLUDE_DIR=/opt/mapkg/include:\$$GCC_INCLUDE_DIR" >> /etc/profile.d/mapkg.sh 
	sudo echo "# End /etc/profile.d/mapkg.sh" >> /etc/profile.d/mapkg.sh
