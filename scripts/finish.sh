#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p "$HOME/.local/state/dev-machine"
if command -v bat >/dev/null; then
    theme=dotfiles/.config/bat/themes/'Catppuccin Mocha.tmTheme'
    checksum=$(shasum -a 256 "$theme" | awk '{print $1}')
    stamp="$HOME/.local/state/dev-machine/bat-theme-sha256"
    if [ ! -f "$stamp" ] || [ "$(cat "$stamp")" != "$checksum" ]; then
        bat cache --build
        printf '%s\n' "$checksum" > "$stamp"
    fi
fi
code_bin='/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
if [ -x "$code_bin" ]; then
    installed=$("$code_bin" --list-extensions)
    for extension in Catppuccin.catppuccin-vsc-pack Catppuccin.catppuccin-vsc-icons; do
        if ! printf '%s\n' "$installed" | grep -qixF "$extension"; then
            "$code_bin" --install-extension "$extension"
        fi
    done
fi
bash scripts/inventory.sh
