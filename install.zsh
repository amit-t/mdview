#!/usr/bin/env zsh
# install.zsh — install (or uninstall) mdview onto PATH.
#
# Usage:
#   ./install.zsh                       # install to ~/.local
#   ./install.zsh --prefix /usr/local   # install system-wide (needs sudo)
#   ./install.zsh --uninstall           # remove from default prefix
#   ./install.zsh --prefix PATH --uninstall
#
# Installs:
#   $PREFIX/bin/mdview                  → symlink to <repo>/bin/mdview
#   $PREFIX/bin/mdv                     → symlink to <repo>/bin/mdview
#   $PREFIX/share/zsh/site-functions/_mdview (if completions/ present)
#
# After install, ensure $PREFIX/bin is on your PATH. For ~/.local:
#   export PATH="$HOME/.local/bin:$PATH"

emulate -L zsh
set -euo pipefail

script_path=${0:A}
repo_root=${script_path:h}
prog=${script_path:t}

prefix="${HOME}/.local"
mode="install"

die() { print -ru2 -- "${prog}: $1"; exit "${2:-1}"; }

while (( $# > 0 )); do
    case "$1" in
        --prefix)    (( $# >= 2 )) || die "--prefix needs a path"
                     prefix="$2"; shift 2 ;;
        --uninstall) mode="uninstall"; shift ;;
        -h|--help)   awk '/^# /{sub(/^# ?/, ""); print; next} {exit}' "$script_path"; exit 0 ;;
        *)           die "unknown flag: $1 (try --help)" 2 ;;
    esac
done

bin_src="$repo_root/bin/mdview"
[[ -x "$bin_src" ]] || die "missing $bin_src"

bin_dir="$prefix/bin"
comp_dir="$prefix/share/zsh/site-functions"

if [[ "$mode" = "uninstall" ]]; then
    for link in "$bin_dir/mdview" "$bin_dir/mdv" "$comp_dir/_mdview"; do
        if [[ -L "$link" || -f "$link" ]]; then
            rm -f -- "$link"
            print -r -- "removed $link"
        fi
    done
    exit 0
fi

mkdir -p -- "$bin_dir"
ln -sfn -- "$bin_src" "$bin_dir/mdview"
ln -sfn -- "$bin_src" "$bin_dir/mdv"
print -r -- "installed $bin_dir/mdview"
print -r -- "installed $bin_dir/mdv"

if [[ -f "$repo_root/completions/_mdview" ]]; then
    mkdir -p -- "$comp_dir"
    ln -sfn -- "$repo_root/completions/_mdview" "$comp_dir/_mdview"
    print -r -- "installed $comp_dir/_mdview"
fi

# PATH guidance — only nag if the chosen bin_dir isn't already on PATH.
if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
    print -r -- ""
    print -r -- "note: $bin_dir is not on your PATH."
    print -r -- "      add this to your shell rc (e.g. ~/.zprofile):"
    print -r -- "        export PATH=\"$bin_dir:\$PATH\""
fi
