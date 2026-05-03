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

## Layout

- `.chezmoiroot` tells chezmoi that `home/` is the source-state root.
- `home/` contains chezmoi-managed files using source-state names such as
  `dot_zshrc.tmpl` and `dot_config/mise/config.toml`.
- `Brewfile` captures macOS/Homebrew packages and casks.
- `home/run_onchange_before_10-install-packages.sh.tmpl` installs packages on
  macOS and Fedora, and skips package installation on other Linux distributions.
- `home/run_onchange_after_20-mise-install.sh.tmpl` installs configured mise
  tools after package setup.

## Notes

Secrets and machine-local auth files intentionally stay out of this repo. That
includes files such as `~/.config/gh/hosts.yml`, Graphite auth, SSH keys, and
application tokens.
