#!/bin/bash
# Converges the Colima VM that serves Docker on every Mac. With --check, only
# reports drift (doctor); without, starts or creates the VM and points the
# Docker CLI at it (apply). A running VM is never restarted here: resizing
# would stop every container on it, so that stays a deliberate step.
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"
profile=default
gib=$((1024 * 1024 * 1024))
# Studios host many worktree databases at once; the minis need one stack.
if [ "$(sysctl -n hw.memsize)" -ge $((256 * gib)) ]; then
    cpus=16 memory=64 disk=120
else
    cpus=4 memory=4 disk=60
fi
compose=/opt/homebrew/opt/docker-compose/bin/docker-compose
plugin="$HOME/.docker/cli-plugins/docker-compose"

vm() { colima list -j | jq -c --arg name "$profile" 'select(.name == $name)'; }
sized() {
    jq -e --argjson cpus "$cpus" --argjson memory $((memory * gib)) --argjson disk $((disk * gib)) \
        '.cpus == $cpus and .memory == $memory and .disk >= $disk' >/dev/null
}

if [ "${1:-}" = --check ]; then
    failures=0
    fail() { echo "$*" >&2; failures=$((failures + 1)); }
    state=$(vm)
    if [ "$(jq -r '.status // empty' <<<"$state")" != Running ]; then
        fail "Colima profile $profile is not running"
    elif ! sized <<<"$state"; then
        fail "Colima profile $profile is not ${cpus} CPU / ${memory} GiB / ${disk} GiB: $state"
    fi
    [ "$(readlink "$plugin" || true)" = "$compose" ] || fail "$plugin does not link to $compose"
    [ "$(docker context show)" = colima ] || fail 'Docker context is not colima'
    docker info --format '{{.ServerVersion}}' >/dev/null || fail 'Docker daemon is unreachable'
    docker compose version >/dev/null || fail 'docker compose is unavailable'
    exit $((failures > 0))
fi

mkdir -p "$(dirname "$plugin")"
[ "$(readlink "$plugin" || true)" = "$compose" ] || ln -sfn "$compose" "$plugin"
state=$(vm)
if [ "$(jq -r '.status // empty' <<<"$state")" != Running ]; then
    colima start "$profile" --cpu "$cpus" --memory "$memory" --disk "$disk" \
        --vm-type vz --mount-type virtiofs
elif ! sized <<<"$state"; then
    echo "Colima profile $profile should be ${cpus} CPU / ${memory} GiB / ${disk} GiB." >&2
    echo "Run 'colima stop $profile' and apply again to resize it." >&2
fi
[ "$(docker context show)" = colima ] || docker context use colima
