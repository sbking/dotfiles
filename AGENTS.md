# Agent Notes

This is a public mise-managed development-machine configuration.

- `dotfiles/` contains literal home-relative files; `[dotfiles]` in `mise.toml` is authoritative.
- Preview with `mise bootstrap --dry-run` and `mise bootstrap dotfiles diff`.
- Back up differing live files before applying; `scripts/backup-dotfiles.sh` is the pre-dotfiles hook.
- Keep tool versions exact and regenerate `mise.lock` when changing them.
- Never run mise bootstrap as root. Only the explicit macOS prerequisites script runs under sudo.
- Use `git-town.toml` as the shared branch-stack configuration. Prefer small,
  dependent branches over broad single-branch changes when a task naturally
  splits into reviewable layers.
- Use Git Town's stack-aware commands instead of raw Git plumbing when updating
  the stack. Prefer `git town sync --stack` for restacking after ancestor
  changes and `git town walk --stack -- <cmd>` for stack-wide validation.
- PR titles are the durable commit subjects for squash merges. Keep every PR
  title in Conventional Commits format before marking it ready or merging it.
- For generated worktrees, use `scripts/setup-git-town-link.sh` to record the
  Git Town parent relationship. Pass the parent explicitly, either as the first
  argument or with `STACK_PARENT_BRANCH`.
- Do not commit secrets or auth state, including `gh/hosts.yml`, Graphite auth, SSH keys, or tokens.
- Keep bootstrap scripts idempotent; they may run on new machines.
