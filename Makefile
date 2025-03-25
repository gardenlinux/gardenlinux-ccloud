SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

ROOT_DIR := $(shell git rev-parse --show-toplevel)

# Default to latest commit if COMMIT is not specified
COMMIT ?= $(shell git ls-remote https://github.com/gardenlinux/gardenlinux.git HEAD | cut -f1)

.PHONY: prepare update clean help ccloud-help

ccloud-help:
	@echo
	@echo "CCloud Custom targets:"
	@echo "  prepare                Initialize submodules and prepare environment"
	@echo "  update [COMMIT=<hash>] Update Garden Linux submodule (to specific commit or latest)"
	@echo "  clean                  Remove Garden Linux submodule and reset environment"
	@echo

help: ccloud-help

-include gardenlinux/Makefile

prepare:
	git submodule update --init --recursive

update:
    # update gardenlinux submodule to specified or latest commit
	cd $(ROOT_DIR)/gardenlinux && git fetch && git checkout $(COMMIT) && cd ..
	git add gardenlinux

    # update workflow commit references
	sed -i -E 's|(gardenlinux/gardenlinux/.github/workflows/[^@]*)@[0-9a-f]{40}|\1@$(COMMIT)|g' $(ROOT_DIR)/.github/workflows/*.y*ml

    # update features
	mkdir -p $(ROOT_DIR)/features
	for feature in $$(ls $(ROOT_DIR)/gardenlinux/features); do \
		if [ -L "$(ROOT_DIR)/features/$$feature" ]; then \
			rm "$(ROOT_DIR)/features/$$feature"; \
		fi; \
		if [ ! -e "$(ROOT_DIR)/features/$$feature" ]; then \
			cd $(ROOT_DIR)/features && ln -s "../gardenlinux/features/$$feature" "$$feature"; \
		fi; \
	done

clean:
	git reset --soft
	rm -rf $(ROOT_DIR)/gardenlinux
	git submodule update --init --recursive
