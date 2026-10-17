#!/bin/bash
# Run from the control checkout: deploy one committed revision to every Mac.
set -euo pipefail
cd "$(dirname "$0")/.."
checkout='Projects/sbking/dotfiles-fleet'
ssh_options=(-o BatchMode=yes -o ConnectTimeout=10)

usage() {
    cat >&2 <<'EOF'
Usage: scripts/fleet.sh status [host...]
       scripts/fleet.sh sync [--force] [host...]
       scripts/fleet.sh add host

status  compare every Mac with this checkout's HEAD; non-zero on any drift
sync    deploy HEAD, converge and run doctor; --force discards remote edits
add     copy HEAD to a new Mac and print the one command to run there
Hosts default to config/fleet-hosts.txt.
EOF
    exit 2
}

remote() { local host=$1; shift; ssh "${ssh_options[@]}" "$host" /bin/bash -s -- "$@"; }

require_clean() {
    test -z "$(git status --porcelain)" || { echo 'Commit or stash local changes first; the fleet only runs committed revisions.' >&2; exit 1; }
}

status_host() {
    remote "$1" "$checkout" "$2" <<'EOF' 2>&1
cd "$HOME/$1" 2>/dev/null || { echo 'FAIL no checkout'; exit 1; }
problems=()
revision=$(git rev-parse HEAD 2>/dev/null || echo none)
test "$revision" = "$2" || problems+=("revision ${revision:0:7}")
edits=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
test "$edits" = 0 || problems+=("$edits edited files")
mise="$HOME/.local/bin/mise"
"$mise" exec -- python3 scripts/check-state.py dotfiles >/dev/null 2>&1 || problems+=('dotfiles drift')
"$mise" exec -- python3 scripts/check-state.py packages >/dev/null 2>&1 || problems+=('packages drift')
"$mise" install --dry-run 2>/dev/null | grep -q . && problems+=('tools missing')
if [ "${#problems[@]}" -gt 0 ]; then (IFS=';'; echo "DRIFT ${problems[*]}"); exit 1; fi
echo "ok ${revision:0:7}"
EOF
}

sync_host() {
    local host=$1 revision=$2 force=$3
    remote "$host" "$checkout" "$force" <<'EOF'
set -euo pipefail
mkdir -p "$HOME/$1"; cd "$HOME/$1"
test -d .git || git init -q
edits=$(git status --porcelain 2>/dev/null || true)
if [ -n "$edits" ] && git rev-parse -q --verify HEAD >/dev/null && [ "$2" != force ]; then
    printf 'Remote checkout has edits; commit them in the control checkout or rerun with --force:\n%s\n' "$edits" >&2
    exit 1
fi
EOF
    git push --quiet --force "$host:$checkout" "$revision:refs/fleet/target"
    remote "$host" "$checkout" <<'EOF'
set -euo pipefail
cd "$HOME/$1"
git checkout --quiet --force --detach refs/fleet/target
git clean --quiet -fd
mise="$HOME/.local/bin/mise"
bash scripts/install-mise.sh >/dev/null
"$mise" trust --quiet
"$mise" bootstrap --yes
"$mise" run bootstrap
"$mise" run doctor
EOF
}

command=${1:-}; shift || usage
force=keep
if [ "${1:-}" = --force ]; then force=force; shift; fi
if [ "$#" -gt 0 ]; then hosts=("$@"); else mapfile -t hosts < <(grep -v '^#' config/fleet-hosts.txt); fi
revision=$(git rev-parse HEAD)
failures=0
case "$command" in
    status)
        results=$(mktemp -d); trap 'rm -rf "$results"' EXIT
        for host in "${hosts[@]}"; do status_host "$host" "$revision" > "$results/$host" & done
        wait
        for host in "${hosts[@]}"; do
            result=$(tail -1 "$results/$host")
            printf '%-14s %s\n' "$host" "${result:-FAIL unreachable}"
            case "$result" in ok*) ;; *) failures=$((failures + 1)) ;; esac
        done
        ;;
    sync)
        require_clean
        logs="${XDG_STATE_HOME:-$HOME/.local/state}/dev-machine/fleet"; mkdir -p "$logs"
        for host in "${hosts[@]}"; do
            if sync_host "$host" "$revision" "$force" > "$logs/$host.log" 2>&1; then
                printf '%-14s ok %s\n' "$host" "${revision:0:7}"
            else
                printf '%-14s FAIL see %s\n' "$host" "$logs/$host.log"; tail -5 "$logs/$host.log" | sed 's/^/    /'
                failures=$((failures + 1))
            fi
        done
        ;;
    add)
        require_clean
        test "$#" = 1 || usage
        git archive "$revision" | ssh "${ssh_options[@]}" "$1" "mkdir -p $checkout && tar -x -C $checkout"
        echo "Copied ${revision:0:7}. Log into that Mac's desktop, then run:"
        echo "  ssh -t $1 /bin/bash $checkout/scripts/new-mac.sh"
        echo "Afterwards add $1 to config/fleet-hosts.txt and run: scripts/fleet.sh sync $1"
        ;;
    *) usage ;;
esac
test "$failures" = 0
