#!/bin/sh
set -eu

usage() {
  cat <<'EOF'
Usage: setup-git-town-link.sh [parent-branch] [child-branch]

Records Git Town parent metadata for a generated worktree.

Parent can also be provided with STACK_PARENT_BRANCH or GIT_TOWN_PARENT_BRANCH.
Child defaults to the current branch.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

if ! git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo "Not in a git repository; skipping Git Town linkage."
  exit 0
fi

cd "$git_root"

parent="${1:-${STACK_PARENT_BRANCH:-${GIT_TOWN_PARENT_BRANCH:-}}}"
child="${2:-$(git branch --show-current)}"

if [ -z "$child" ]; then
  echo "No current branch detected; skipping Git Town linkage."
  exit 0
fi

case "$child" in
  main|master)
    echo "Current branch is $child; skipping Git Town linkage."
    exit 0
    ;;
esac

config_key="git-town-branch.$child.parent"
existing_parent="$(git config --get "$config_key" || true)"

if [ -z "$parent" ]; then
  if [ -n "$existing_parent" ]; then
    echo "Git Town parent already set: $child -> $existing_parent"
  else
    echo "No parent branch supplied; set STACK_PARENT_BRANCH or pass the parent branch as the first argument."
  fi
  exit 0
fi

if [ "$parent" = "$child" ]; then
  echo "Parent branch cannot equal child branch: $child" >&2
  exit 1
fi

git config "$config_key" "$parent"
echo "Git Town parent set: $child -> $parent"
