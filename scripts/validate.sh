#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
git diff --check
for script in scripts/*.sh dotfiles/.local/bin/*; do bash -n "$script"; done
if command -v fish >/dev/null; then fish -n dotfiles/.config/fish/config.fish; fi
if command -v zsh >/dev/null; then zsh -n dotfiles/.zshrc; zsh -n dotfiles/.zprofile; fi
python3 scripts/validate-config.py
mise tasks ls >/dev/null
echo 'Configuration validation passed.'
