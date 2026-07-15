#!/usr/bin/env bash

set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link_file() {
    local source="$1"
    local target="$2"

    mkdir -p "$(dirname "$target")"

    if [ -L "$target" ]; then
        echo "Removing existing symlink: $target"
        rm "$target"
    elif [ -e "$target" ] ; then
        echo "Backing up existing file: $target"
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
    fi

    echo "Linking $target -> $source"
    ln -s "$source" "$target"
}

echo "Installing dotfiles from: $DOTFILES_DIR"

link_file "$DOTFILES_DIR/bash/bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/bash" "$HOME/.config/bash"

if [ ! -f "$DOTFILES_DIR/bash/local.sh" ]; then
    echo "Creating private local file: $DOTFILES_DIR/bash/local.sh"
    cp "$DOTFILES_DIR/bash/local.sh.example" "$DOTFILES_DIR/bash/local.sh"
fi

echo "Done."
echo "Reload with: source ~/.bashrc"
