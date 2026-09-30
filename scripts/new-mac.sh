#!/bin/bash
# Run once on a fresh Mac, as the development account, from an interactive terminal.
set -euo pipefail
cd "$(dirname "$0")/.."
test "$(uname -s)" = Darwin || { echo 'macOS required' >&2; exit 1; }
test "$EUID" != 0 || { echo 'Run as the development account; sudo is requested when needed.' >&2; exit 1; }
test "$(stat -f %Su /dev/console)" = "$(id -un)" || { echo 'Log into the macOS desktop as this account first; the Tailscale installer needs it.' >&2; exit 1; }

sudo bash scripts/macos-admin.sh
bash scripts/install-mise.sh
mise="$HOME/.local/bin/mise"
"$mise" trust --quiet
"$mise" bootstrap --yes
"$mise" run bootstrap

cat <<'EOF'

Remaining manual steps:
1. System Settings → General → Login Items & Extensions → Network Extensions: approve Tailscale, then allow its VPN configuration.
2. TAILSCALE_BE_CLI=1 /Applications/Tailscale.app/Contents/MacOS/Tailscale up --timeout=30s
   Open the printed link and choose the intended tailnet account.
3. Sign into GitHub and the desktop applications.
Then, from the control checkout: scripts/fleet.sh sync <this host>
EOF
