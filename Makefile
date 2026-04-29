SHELL := /usr/bin/env zsh
PREFIX ?= $(HOME)/.local

.PHONY: help test lint install uninstall version clean

help:
	@print -r -- "mdview — usage:"
	@print -r -- "  make test                  run end-to-end test suite"
	@print -r -- "  make lint                  zsh -n parse-check all scripts"
	@print -r -- "  make install [PREFIX=...]  symlink mdview + mdv into PREFIX/bin (default ~/.local)"
	@print -r -- "  make uninstall [PREFIX=.]  remove the symlinks"
	@print -r -- "  make version               print mdview --version"

test:
	@zsh tests/test-mdview.zsh

lint:
	@zsh -n bin/mdview
	@zsh -n tests/test-mdview.zsh
	@zsh -n install.zsh
	@print -r -- "lint: ok"

install:
	@./install.zsh --prefix "$(PREFIX)"

uninstall:
	@./install.zsh --prefix "$(PREFIX)" --uninstall

version:
	@./bin/mdview --version

clean:
	@rm -rf /tmp/mdview.* 2>/dev/null || true
	@print -r -- "clean: ok"
