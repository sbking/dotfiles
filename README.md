# sbking/dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). macOS and
Fedora are currently configured; other platforms may be added later.

## Quick Start

On a new machine:

```sh
chezmoi init --apply https://github.com/sbking/dotfiles.git
```

On this machine, while working from this checkout:

```sh
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply
```

See [docs/bootstrap.md](docs/bootstrap.md) for first-machine setup, local
validation, and stack workflow notes.

## Layout

- `.codex/environments/` contains repo-local Codex environment definitions for
  worktree setup.
- `.chezmoiroot` tells chezmoi that `home/` is the source-state root.
- `git-town.toml` captures the shared branch-stack workflow for Git Town.
- `scripts/` contains helper scripts used by local tools and setup flows.
- `scripts/validate.sh` runs the local validation suite; `mise run validate`
  and `mise run validate:quick` wrap it.
- `home/` contains chezmoi-managed files using source-state names such as
  `dot_zshrc.tmpl` and `dot_config/mise/config.toml`.
- `Brewfile` captures macOS/Homebrew packages and casks.
- `home/run_onchange_before_10-install-packages.sh.tmpl` installs packages on
  macOS and Fedora, and skips package installation on other Linux distributions.
- `home/run_onchange_after_20-mise-install.sh.tmpl` installs configured mise
  tools after package setup.

## Branch Stacks

This repo uses Git Town for local branch-stack metadata. Keep stacked changes
small and independently reviewable. Create dependent work on top of its parent
branch, then record the relationship with Git Town before opening or updating
pull requests.

Use Git Town's stack-aware commands for common stack maintenance:

```sh
git town sync --stack
git town walk --stack -- git diff --check
git town diff-parent
```

When an agent creates a new worktree for a stacked change, run:

```sh
STACK_PARENT_BRANCH=feat/parent-branch ./scripts/setup-git-town-link.sh
```

The same command can be used from Codex or T3Code setup scripts. The repo also
includes `.codex/environments/git-town-stack.toml` as a Codex environment
wrapper for this helper; set the parent branch before using it for a specific
stacked child.

## Notes

Secrets and machine-local auth files intentionally stay out of this repo. That
includes files such as `~/.config/gh/hosts.yml`, Graphite auth, SSH keys, and
application tokens. Codex app-generated state such as marketplace cache paths,
session databases, and per-project trust entries also stays machine-local.
