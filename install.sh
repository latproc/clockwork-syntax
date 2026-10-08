#!/bin/sh
#
# install.sh -- install the Clockwork syntax files for Vim and Neovim.
#
# Straight from the internet:
#
#     curl -fsSL https://raw.githubusercontent.com/latproc/clockwork-syntax/master/install.sh | sh
#
# From a checkout:
#
#     ./install.sh
#
# Everything lands in a Vim package directory, so there is no runtimepath to
# edit and no existing file in ~/.vim/{syntax,ftdetect} is touched:
#
#     ~/.vim/pack/clockwork/start/clockwork/{syntax,ftdetect,ftplugin,doc}
#
# Neovim is pointed at the same package with a symlink when it has a config
# directory of its own, so both editors update together.
#
# Options:
#     --ref REF       git ref to download (default: master)
#     --url URL       tarball URL, overrides --ref
#     --vim-dir DIR   Vim base directory (default: $HOME/.vim)
#     --nvim-dir DIR  Neovim base directory (default: $XDG_CONFIG_HOME/nvim)
#     --no-nvim       leave the Neovim configuration alone
#     --uninstall     remove what this script installed
#     -h, --help      this text
#
# No sudo, no writes outside those two directories.

set -eu

REPO=latproc/clockwork-syntax
REF=master
URL=
VIMDIR=${HOME:-/tmp}/.vim
NVIMDIR=${XDG_CONFIG_HOME:-${HOME:-/tmp}/.config}/nvim
DO_NVIM=yes
DO_UNINSTALL=no
PACK=clockwork
PLUGIN=clockwork

usage() {
    if [ -f "$0" ]; then
        awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "$0"
    else
        echo "Clockwork syntax installer -- see https://github.com/$REPO"
    fi
    exit "${1:-0}"
}

die() {
    echo "install.sh: $*" >&2
    exit 1
}

note() {
    echo "install.sh: $*"
}

while [ $# -gt 0 ]; do
    case $1 in
        --ref)        [ $# -ge 2 ] || die "--ref needs a value"; REF=$2; shift 2 ;;
        --url)        [ $# -ge 2 ] || die "--url needs a value"; URL=$2; shift 2 ;;
        --vim-dir)    [ $# -ge 2 ] || die "--vim-dir needs a value"; VIMDIR=$2; shift 2 ;;
        --nvim-dir)   [ $# -ge 2 ] || die "--nvim-dir needs a value"; NVIMDIR=$2; shift 2 ;;
        --no-nvim)    DO_NVIM=no; shift ;;
        --uninstall)  DO_UNINSTALL=yes; shift ;;
        -h|--help)    usage 0 ;;
        *)            die "unknown option: $1 (try --help)" ;;
    esac
done

VIM_PACK=$VIMDIR/pack/$PACK
VIM_DEST=$VIM_PACK/start/$PLUGIN
NVIM_PACK=$NVIMDIR/pack/$PACK
NVIM_DEST=$NVIM_PACK/start/$PLUGIN

# --------------------------------------------------------------------------
# uninstall
# --------------------------------------------------------------------------
if [ "$DO_UNINSTALL" = yes ]; then
    removed=no
    if [ -d "$VIM_PACK" ]; then
        if rm -rf "$VIM_PACK"; then
            note "removed $VIM_PACK"
            removed=yes
        fi
    fi
    if [ -L "$NVIM_PACK" ]; then
        if rm -f "$NVIM_PACK"; then
            note "removed symlink $NVIM_PACK"
            removed=yes
        fi
    elif [ -d "$NVIM_PACK/start/$PLUGIN" ]; then
        if rm -rf "$NVIM_PACK"; then
            note "removed $NVIM_PACK"
            removed=yes
        fi
    fi
    if [ "$removed" = no ]; then
        note "nothing installed under $VIMDIR or $NVIMDIR"
    fi
    exit 0
fi

# --------------------------------------------------------------------------
# find the files: a local checkout if we are one, otherwise download
# --------------------------------------------------------------------------
tmp=$(mktemp -d) || die "cannot create a temporary directory"
trap 'rm -rf "$tmp"' EXIT INT TERM

self=$0
src=
if [ -f "$self" ]; then
    selfdir=$(CDPATH= cd -- "$(dirname -- "$self")" && pwd)
    if [ -f "$selfdir/vi/$PLUGIN/syntax/$PLUGIN.vim" ]; then
        src=$selfdir/vi/$PLUGIN
        note "using the checkout at $selfdir"
    fi
fi

if [ -z "$src" ]; then
    [ -n "$URL" ] || URL=https://codeload.github.com/$REPO/tar.gz/refs/heads/$REF
    note "downloading $URL"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$URL" -o "$tmp/src.tar.gz" || die "download failed"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$URL" -O "$tmp/src.tar.gz" || die "download failed"
    else
        die "neither curl nor wget is available"
    fi

    mkdir -p "$tmp/unpacked"
    tar -xzf "$tmp/src.tar.gz" -C "$tmp/unpacked" || die "could not unpack the tarball"

    src=
    for dir in "$tmp/unpacked"/*/vi/$PLUGIN; do
        if [ -f "$dir/syntax/$PLUGIN.vim" ]; then
            src=$dir
        fi
    done
    [ -n "$src" ] || die "the archive does not contain vi/$PLUGIN/syntax/$PLUGIN.vim"
fi

for f in syntax/$PLUGIN.vim ftdetect/$PLUGIN.vim; do
    [ -f "$src/$f" ] || die "missing $src/$f -- refusing to install a partial tree"
done

# --------------------------------------------------------------------------
# install into the Vim package directory
# --------------------------------------------------------------------------
mkdir -p "$VIM_PACK/start" || die "cannot create $VIM_PACK/start"
rm -rf "$VIM_DEST"
mkdir -p "$VIM_DEST"
cp -R "$src"/. "$VIM_DEST"/ || die "copy to $VIM_DEST failed"
note "installed $VIM_DEST"

# --------------------------------------------------------------------------
# Neovim: share the same package when we can, copy when we must
# --------------------------------------------------------------------------
if [ "$DO_NVIM" = yes ] && [ -d "$NVIMDIR" ] && [ "$NVIMDIR" != "$VIMDIR" ]; then
    if [ -L "$NVIM_PACK" ]; then
        rm -f "$NVIM_PACK"
        if ln -s "$VIM_PACK" "$NVIM_PACK"; then
            note "linked $NVIM_PACK -> $VIM_PACK"
        fi
    elif [ ! -e "$NVIM_PACK" ]; then
        mkdir -p "$NVIMDIR/pack"
        if ln -s "$VIM_PACK" "$NVIM_PACK" 2>/dev/null; then
            note "linked $NVIM_PACK -> $VIM_PACK"
        else
            mkdir -p "$NVIM_DEST"
            cp -R "$src"/. "$NVIM_DEST"/
            note "installed $NVIM_DEST (symlink not supported here)"
        fi
    else
        mkdir -p "$NVIM_DEST"
        rm -rf "$NVIM_DEST"
        cp -R "$src"/. "$NVIM_DEST"/
        note "installed $NVIM_DEST"
    fi
fi

# --------------------------------------------------------------------------
# help tags, if the editor is here to build them
# --------------------------------------------------------------------------
if [ -d "$VIM_DEST/doc" ]; then
    if command -v vim >/dev/null 2>&1; then
        vim -es -Nu NONE -N -c "helptags $VIM_DEST/doc" -c 'qa!' >/dev/null 2>&1 || true
    fi
fi

# --------------------------------------------------------------------------
# smoke test: does the filetype actually pick the syntax up?
# --------------------------------------------------------------------------
if command -v vim >/dev/null 2>&1; then
    printf 'STATE SET LOG\nidle INITIAL { x := 0x10 + 1.5; }\n' > "$tmp/smoke.cw"
    printf 'let g:out = synIDattr(synID(1,1,1), "name")\ncall writefile([g:out], "%s")\nqa!\n' "$tmp/smoke.out" > "$tmp/smoke.vim"
    if vim -es -Nu NONE -N --cmd "set rtp^=$VIM_DEST" \
           -c 'syntax on' -c 'set ft=clockwork' -S "$tmp/smoke.vim" "$tmp/smoke.cw" >/dev/null 2>&1
    then
        got=$(cat "$tmp/smoke.out" 2>/dev/null || echo '')
        case $got in
            cwKeyword) note "smoke test OK (STATE highlights as $got)" ;;
            '')        note "warning: smoke test produced no result" ;;
            *)         note "warning: smoke test expected cwKeyword, got '$got'" ;;
        esac
    else
        note "warning: could not run the Vim smoke test"
    fi
else
    note "Vim is not on PATH here -- skipped the smoke test"
fi

note "done. Open a .cw or .lpc file, or use :set ft=clockwork in a running editor."
