if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lah --git --group-directories-first --icons=auto'
  alias la='eza -a --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
else
  alias ll='ls -lah'
fi

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
