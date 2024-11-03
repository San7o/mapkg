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
