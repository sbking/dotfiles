#!/bin/sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
quick=false
rendered="${TMPDIR:-/tmp}/dotfiles-validate-rendered-$$.sh"

cleanup() {
  rm -f "$rendered"
}
trap cleanup EXIT HUP INT TERM

case "${1:-}" in
  --quick)
    quick=true
    ;;
  -h|--help)
    cat <<'EOF'
Usage: scripts/validate.sh [--quick]

Runs repo-local validation for these chezmoi dotfiles.

--quick skips checks that may start external tools or render live machine state.
EOF
    exit 0
    ;;
  "")
    ;;
  *)
    echo "Unknown argument: $1" >&2
    exit 2
    ;;
esac

cd "$repo_root"

run() {
  printf '\n==> %s\n' "$*"
  "$@"
}

if command -v git >/dev/null 2>&1; then
  run git diff --check
fi

if command -v sh >/dev/null 2>&1; then
  for file in scripts/*.sh; do
    [ -f "$file" ] || continue
    run sh -n "$file"
  done
fi

if command -v fish >/dev/null 2>&1; then
  run fish -n home/dot_config/fish/config.fish
else
  echo "Skipping fish syntax check: fish is not installed."
fi

if command -v zsh >/dev/null 2>&1; then
  run zsh -n home/dot_zshrc
  for file in home/dot_config/zsh/*.zsh; do
    [ -f "$file" ] || continue
    run zsh -n "$file"
  done
else
  echo "Skipping zsh syntax check: zsh is not installed."
fi

if command -v chezmoi >/dev/null 2>&1; then
  for file in home/run_*.sh.tmpl home/dot_zprofile.tmpl; do
    [ -f "$file" ] || continue
    printf '\n==> chezmoi execute-template < %s | sh -n\n' "$file"
    chezmoi --source "$repo_root" execute-template < "$file" > "$rendered"
    sh -n "$rendered"
    rm -f "$rendered"
  done
  run chezmoi --source "$repo_root" doctor --no-network
  run chezmoi --source "$repo_root" diff --no-pager
else
  echo "Skipping chezmoi checks: chezmoi is not installed."
fi

if [ "$quick" = true ]; then
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  run env HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$repo_root/Brewfile"
else
  echo "Skipping Homebrew bundle check: brew is not installed."
fi

if command -v fastfetch >/dev/null 2>&1 && [ -f home/dot_config/fastfetch/config.jsonc ]; then
  run fastfetch --config home/dot_config/fastfetch/config.jsonc --pipe false
else
  echo "Skipping fastfetch config check: fastfetch or config is not available."
fi

if command -v tmux >/dev/null 2>&1 && [ -f home/dot_config/tmux/tmux.conf ]; then
  run tmux -f "$repo_root/home/dot_config/tmux/tmux.conf" start-server \; source-file "$repo_root/home/dot_config/tmux/tmux.conf" \; display-message ok \; kill-server
else
  echo "Skipping tmux config check: tmux or config is not available."
fi
