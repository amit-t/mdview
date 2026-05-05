#!/usr/bin/env zsh
# aliases.zsh — shell aliases for mdview.
#
# Source from your shell rc (e.g. ~/.zprofile):
#   source ${HOME}/Projects/Libraries/mdview/aliases.zsh
#
# Resolution order:
#   1. mdview already on PATH (e.g. via `install.zsh` symlink in ~/.local/bin)
#      → only define `mdv` shorthand if it isn't already on PATH.
#   2. Fall back to repo checkout at this script's directory.
#   3. Otherwise: define nothing — no error spam at shell startup.

# ${(%):-%N} = path of the file being sourced (zsh prompt expansion).
_mdview_repo=${${(%):-%N}:A:h}
_mdview_bin="${_mdview_repo}/bin/mdview"

if (( $+commands[mdview] )); then
    (( $+commands[mdv] )) || alias mdv="mdview"
elif [[ -x "$_mdview_bin" ]]; then
    alias mdview="$_mdview_bin"
    alias mdv="$_mdview_bin"
fi

unset _mdview_repo _mdview_bin
