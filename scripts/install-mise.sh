#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
version=$(cat config/mise-version)
case "$(uname -s)-$(uname -m)" in
    Darwin-arm64) platform=macos-arm64 ;;
    Linux-x86_64) platform=linux-x64 ;;
    *) echo 'Unsupported bootstrap platform' >&2; exit 1 ;;
esac
asset="mise-v$version-$platform"
expected=$(awk -v asset="$asset" '$2 == asset {print $1}' config/mise-sha256.txt)
test -n "$expected"
hash() { if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | awk '{print $1}'; }
target="$HOME/.local/bin/mise"
if [ -f "$target" ] && [ "$(hash "$target")" = "$expected" ]; then
    echo "mise $version already installed and checksum verified"; exit 0
fi
mkdir -p "$HOME/.local/bin"
tmp=$(mktemp "$HOME/.local/bin/.mise-install.XXXXXX")
trap 'rm -f "$tmp"' EXIT
curl --fail --location --retry 3 "https://github.com/jdx/mise/releases/download/v$version/$asset" -o "$tmp"
test "$(hash "$tmp")" = "$expected" || { echo 'mise checksum mismatch' >&2; exit 1; }
chmod 0755 "$tmp"
mv "$tmp" "$target"
"$target" --version
