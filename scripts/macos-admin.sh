#!/bin/bash
# Run with sudo; performs only the host-level prerequisites for mise.
set -euo pipefail
test "$(uname -s)" = Darwin || { echo 'macOS required' >&2; exit 1; }
test "$EUID" = 0 || { echo 'Run: sudo bash scripts/macos-admin.sh' >&2; exit 1; }
dev_user=${SUDO_USER:?Run through sudo as the development account}
test "$dev_user" != root
dev_group=$(id -gn "$dev_user")

echo 'Checking Xcode Command Line Tools updates'
marker=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
created_marker=false
if [ ! -e "$marker" ]; then touch "$marker"; created_marker=true; fi
cleanup() { if "$created_marker"; then rm -f "$marker"; fi; }
trap cleanup EXIT
available=$(/usr/sbin/softwareupdate --list 2>&1)
printf '%s\n' "$available"
clt_label=$(printf '%s\n' "$available" | sed -n 's/^\* Label: \(Command Line Tools.*\)/\1/p' | sort -V | tail -1)
if [ -n "$clt_label" ]; then
    /usr/sbin/softwareupdate --install "$clt_label"
fi
if ! /usr/bin/xcrun --find clang >/dev/null 2>&1; then
    /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
fi
/usr/bin/xcrun --find clang

if [ ! -d /opt/homebrew ]; then
    install -d -o "$dev_user" -g "$dev_group" -m 0755 /opt/homebrew
fi
sudo -u "$dev_user" test -w /opt/homebrew || { echo '/opt/homebrew is not writable by the development account' >&2; exit 1; }

/usr/bin/pmset -a sleep 0 autorestart 1 womp 1
for key in AutomaticCheckEnabled AutomaticDownload AutomaticallyInstallMacOSUpdates CriticalUpdateInstall ConfigDataInstall; do
    defaults write /Library/Preferences/com.apple.SoftwareUpdate "$key" -bool true
done
defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
echo 'Host prerequisites complete. No reboot required.'
