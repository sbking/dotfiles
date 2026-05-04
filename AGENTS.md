# Agent Notes

This is a public chezmoi dotfiles repo. macOS and Fedora are currently
configured; other platforms may be added later.

- `.chezmoiroot` points at `home/`; treat `home/` as the chezmoi source-state root.
- Preview target changes with `chezmoi --source "$PWD" diff` from the repo root.
- Run `chezmoi --source "$PWD" apply` only when intentionally updating this machine's live dotfiles.
- Use `git-town.toml` as the shared branch-stack configuration. Prefer small,
  dependent branches over broad single-branch changes when a task naturally
  splits into reviewable layers.
- Use Git Town's stack-aware commands instead of raw Git plumbing when updating
  the stack. Prefer `git town sync --stack` for restacking after ancestor
  changes and `git town walk --stack -- <cmd>` for stack-wide validation.
- Do not commit secrets or auth state, including `gh/hosts.yml`, Graphite auth, SSH keys, or tokens.
- Keep bootstrap scripts idempotent; they may run on new machines.
