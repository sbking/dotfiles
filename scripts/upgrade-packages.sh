#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Existing Homebrew-owned casks cannot be upgraded by mise (receipt ownership).
if command -v brew >/dev/null; then
    brew update
    brew upgrade --cask
fi
mise bootstrap packages upgrade
bash scripts/inventory.sh
