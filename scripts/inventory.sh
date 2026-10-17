#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
state="$HOME/.local/state/dev-machine"
mkdir -p "$state"
tmp=$(mktemp "$state/inventory.XXXXXX")
trap 'rm -f "$tmp"' EXIT
{
    date -u
    hostname
    sw_vers
    echo "Configuration revision: $(git rev-parse HEAD)"
    git status --short
    mise --version
    mise ls --current
    mise bootstrap packages status
    xcode-select -p
    pkgutil --pkg-info com.apple.pkg.CLTools_Executables || true
    pmset -g custom
} > "$tmp" 2>&1
mv "$tmp" "$state/inventory.txt"
echo "Inventory: $state/inventory.txt"
