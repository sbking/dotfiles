# Bootstrap

This repo is a public chezmoi source-state checkout. Bootstrap should stay
idempotent because these steps may run on fresh machines and on machines that
already have partial setup.

## New Machine

Install from GitHub:

```sh
chezmoi init --apply https://github.com/sbking/dotfiles.git
```

The first apply runs the package setup scripts for the detected platform, then
installs configured mise tools. On macOS, package state comes from `Brewfile`.
On Fedora, `home/run_onchange_before_10-install-packages.sh.tmpl` installs
packages with `dnf`. Other Linux distributions skip package installation.

After the first apply, open a new shell and run:

```sh
chezmoi doctor --no-network
fastfetch
```

If fish was installed and configured as the login shell, start a fresh terminal
session before judging shell behavior.

## Existing Checkout

From the repo root, preview and apply intentionally:

```sh
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply
```

Run the local validation suite:

```sh
mise trust
mise run validate
```

For a faster pre-commit pass:

```sh
mise run validate:quick
```

## Stack Workflow

Keep work in dependent branches and record each parent with Git Town. When
creating a generated worktree, pass the parent explicitly:

```sh
STACK_PARENT_BRANCH=feat/parent-branch ./scripts/setup-git-town-link.sh
```

Before pushing or opening PRs, validate the current branch or walk the stack:

```sh
scripts/validate.sh --quick
git town walk --stack -- git diff --check
```

## Secrets

Do not apply or commit machine-local auth state. Keep files like `gh/hosts.yml`,
Graphite auth, SSH keys, and application tokens out of this repo.
