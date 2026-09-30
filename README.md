# Development Macs, managed with mise

One versioned configuration for `mac-studio-a`, `mac-studio-b`, `mac-mini-a`, and `mac-mini-b`.
The supported provisioning target is Apple Silicon macOS. The existing shell/editor configs remain portable; this rollout does not provision Fedora.

## New Mac

1. On the Mac: enable Remote Login for the development account, enroll its authorized SSH public keys, and log into the desktop.
2. From the control checkout: `scripts/fleet.sh add <host>`, then run the one command it prints. That command asks for the administrator password once, installs the pinned mise, converges the machine and lists the remaining manual steps (Tailscale approval and sign-ins).
3. Add the host to `config/fleet-hosts.txt`, commit, and run `scripts/fleet.sh sync <host>`.

## Keeping the fleet in sync

The control checkout is the single source of truth; the Macs only ever run a committed revision and are never edited in place.

```sh
scripts/fleet.sh status   # one line per Mac; non-zero on any drift
scripts/fleet.sh sync     # deploy HEAD to every Mac, converge, run doctor
```

`sync` refuses a Mac whose checkout has local edits; move them into a commit here, or pass `--force` to discard them. Logs are kept in `~/.local/state/dev-machine/fleet/`.

## Everyday commands

```sh
dev-machine status     # inspect declared state
dev-machine apply      # converge the current checkout
dev-machine doctor     # verify the development environment
dev-machine inventory  # record installed versions and Git revision
dev-machine updates    # inspect available updates
dev-machine upgrade:packages # deliberately upgrade native packages/apps
```

Use the full `~/.local/bin/mise` path during initial setup. Project mise configurations override the shared global tool versions.

## Reproducibility boundaries

- The mise executable is pinned and checksum-verified. Developer tools use exact versions and a committed `mise.lock` with platform download metadata where supported (Rust/rustup and npm do not provide all platform URLs).
- Catppuccin tmux and Neovim sources are pinned to commits.
- Graphite uses its pinned official npm package because the released mise binary does not support its tap metadata. Parsec remains an optional legacy application on Studio A; its cask lifecycle is unsupported by this mise release. RustDesk and SSH are in the shared baseline.

- Native `brew:` formulae and `brew-cask:` apps use current upstream releases. Homebrew does not retain every old bottle; this is repeatable convergence, **not a bit-for-bit OS image**. Actual versions and the configuration revision are saved in `~/.local/state/dev-machine/inventory.txt`.
- App Store apps, self-updating GUI apps, and VS Code marketplace extensions have their own update lifecycles. `updates` reports what can be queried; it does not silently bump pinned project runtimes.
- macOS automatic updates stay enabled. Major OS updates and reboots are supervised over SSH with interactive authentication.
- Private SSH keys, authorized keys, tokens, app sessions, and Git identity overrides are never copied by bootstrap. Keep identity in `~/.gitconfig.local`.

## Migration and recovery

mise replaces chezmoi as the active owner of these files. No chezmoi hook is run by the new bootstrap.
Before overwriting a differing managed file, the pre-dotfiles hook copies it under `~/.local/state/dev-machine/backups/<timestamp>/`.
Only the paths in `config/managed-paths.txt` are touched. Restore selected files from a backup if needed; keep local customizations in source before the next apply.

Existing Homebrew formulae satisfy mise's package declarations. Studio A's existing Homebrew-owned casks retain their receipts: the explicit upgrade task uses Homebrew for those, then mise for its packages. Fresh Macs do not require the Homebrew CLI. Do not delete cask receipts to transfer ownership.

The previous chezmoi checkout and installed tool versions are retained on Studio A for recovery. No package pruning is automatic.

## Development

`mise run validate` checks configuration, exact tool pins, the managed-file manifest, shell syntax and JSON. After editing tool versions, keep the global tool config in sync, regenerate `mise.lock` on a Mac and copy it to `dotfiles/.config/mise/mise.lock`. Global tools install in locked mode, so an install never rewrites the deployed lock.

See [bootstrap details](docs/bootstrap.md). Keep changes on Git Town branches with Conventional Commit PR titles; do not commit credentials or machine-generated inventory.
