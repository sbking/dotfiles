#!/bin/bash
set -uo pipefail
cd "$(dirname "$0")/.."
failed=0
run() { echo; echo "==> $*"; "$@" || failed=1; }
run softwareupdate --list
run mise outdated --bump
run mise bootstrap packages status
if command -v brew >/dev/null; then run env HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --greedy; fi
if command -v mas >/dev/null; then run mas outdated; fi
echo 'Host package status checks presence; use upgrade:packages to resolve and apply newer package releases.'
exit "$failed"
