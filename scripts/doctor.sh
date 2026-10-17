#!/bin/bash
set -uo pipefail
cd "$(dirname "$0")/.."
failures=0
check() { echo "Checking: $*"; "$@" || failures=$((failures + 1)); }
check test "$(mise --version | awk '{print $1}')" = "$(cat config/mise-version)"
check xcrun --find clang
check python3 scripts/check-state.py dotfiles
check python3 scripts/check-state.py packages
check python3 scripts/check-tailscale.py
check test "$(dscl . -read "/Users/$(id -un)" UserShell | awk '{print $2}')" = /opt/homebrew/bin/fish
check grep -qxF /opt/homebrew/bin/fish /etc/shells
for tool in node pnpm bun python uv rustc cargo go codex jj jjui starship; do
    check command -v "$tool"
done
check node --version
check pnpm --version
check python --version
check rustc --version
check go version
check fish -lc 'command -v node; command -v pnpm; command -v mise'
check zsh -lc 'command -v node; command -v pnpm; command -v mise'
check test -s "$HOME/.ssh/authorized_keys"
check test "$(stat -f %Lp "$HOME/.ssh")" = 700
check test "$(stat -f %Lp "$HOME/.ssh/authorized_keys")" = 600
check bash -c 'pmset -g custom | grep -Eq "^[[:space:]]*sleep[[:space:]]+0$"'
check bash -c 'pmset -g custom | grep -Eq "^[[:space:]]*autorestart[[:space:]]+1$"'
if [ "$failures" -gt 0 ]; then echo "$failures checks failed" >&2; exit 1; fi
echo 'Development machine checks passed.'
echo 'GitHub and application logins remain machine-local; verify the intended tailnet and peer reachability separately.'
