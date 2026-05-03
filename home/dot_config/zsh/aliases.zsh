alias ll='ls -lah'
alias gs='git status --short --branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --decorate --graph -20'

if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi
