# Development Macs, managed with mise

One versioned configuration for `mac-studio-a`, `mac-studio-b`, `mac-mini-a`, and `mac-mini-b`.
The supported provisioning target is Apple Silicon macOS. The existing shell/editor configs remain portable; this rollout does not provision Fedora.

## New Mac

1. Enable Remote Login for the development account and enroll its authorized SSH public keys separately.
2. Clone this repository at `~/Projects/sbking/dotfiles-fleet` (or transfer a verified Git bundle if Command Line Tools are not installed yet).
3. Run `sudo bash scripts/macos-admin.sh` for Command Line Tools, the package prefix, power settings and automatic OS/App Store updates.
4. Run `bash scripts/install-mise.sh`. This installs mise **2026.9.1** from an official release with a checked-in SHA-256.
5. Run `~/.local/bin/mise trust`, preview with `~/.local/bin/mise bootstrap --dry-run`, then run `~/.local/bin/mise bootstrap --yes`.
6. Start a fresh SSH/login session, then run `dev-machine doctor` and complete GitHub, Tailscale and application sign-ins on this machine.

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

- The mise executable is pinned and checksum-verified. Developer tools use exact versions and a committed `mise.lock` with platform download metadata.
- Catppuccin tmux and Neovim sources are pinned to commits.
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

`mise run validate` checks configuration, exact tool pins, the managed-file manifest, shell syntax and JSON. After editing tool versions, keep the global tool config in sync and regenerate `mise.lock` for `macos-arm64,linux-x64`.

See [bootstrap details](docs/bootstrap.md). Keep changes on Git Town branches with Conventional Commit PR titles; do not commit credentials or machine-generated inventory.
