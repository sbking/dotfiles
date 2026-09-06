#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
backup="$HOME/.local/state/dev-machine/backups/$(date -u +%Y%m%dT%H%M%SZ)-$$"
while IFS= read -r rel; do
    target="$HOME/$rel"
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ ! -L "$target" ] && cmp -s "dotfiles/$rel" "$target"; then continue; fi
        mkdir -p "$backup/$(dirname "$rel")"
        cp -pP "$target" "$backup/$rel"
        echo "Backed up $target"
    fi
done < config/managed-paths.txt
if [ -d "$backup" ]; then echo "Previous dotfiles: $backup"; fi
