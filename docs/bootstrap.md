# Bootstrap details

The public configuration contains machine-independent defaults. `config/mise-version`, `config/mise-sha256.txt`, `[tools]` and `mise.lock` define the versioned toolchain.

Run prerequisite and bootstrap commands as the development user, using sudo **only** for `scripts/macos-admin.sh` and when mise explicitly prompts for a privileged operation. Never run the entire mise bootstrap as root.

## Layout

- `mise.toml`: packages, pinned tools, managed dotfiles, repositories, shell and tasks.
- `dotfiles/`: literal home-relative files, copied by mise; no chezmoi filename encoding.
- `scripts/`: idempotent prerequisites, backups, validation, inventory and maintenance.
- `config/managed-paths.txt`: audited backup scope; validated against `[dotfiles]`.

The expected installed checkout is `~/Projects/sbking/dotfiles-fleet`; `dev-machine` uses that durable path. Bootstrap never links files to an ephemeral remote staging directory.

## Host inventory

| Host | Chip | Memory | Role |
| --- | --- | --- | --- |
| mac-studio-a.local | M3 Ultra | 512 GiB | Development workstation |
| mac-studio-b.local | M3 Ultra | 512 GiB | Development workstation |
| mac-mini-a.local | M4 | 16 GiB | Development workstation |
| mac-mini-b.local | M4 | 16 GiB | Development workstation |

All four were verified on macOS 26.6.2 (25G83) before rollout. Use hostnames, not DHCP addresses. The same software is installed; workload concurrency and large caches should reflect available resources.

## Authentication and restart

Public-key SSH is enrolled separately. A restart can leave an Apple Silicon Mac waiting for a password unlock; normal public-key authentication resumes after unlocking. Passwords are entered directly in an interactive SSH terminal, never stored in configuration.

Tailscale installation does not enroll the machine. Open Tailscale and authenticate on each Mac. GUI application permissions and account logins are deliberately manual.

## Checks

Preview before apply: `mise bootstrap --dry-run` and `mise bootstrap dotfiles diff`.
After apply: `mise run doctor`, fresh interactive and non-interactive SSH commands, then a second apply to confirm convergence.
`mise bootstrap status` inspects configuration state; inventory records versions. A clean result does not prove user logins or external account connectivity.
