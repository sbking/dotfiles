if not contains -- "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
end

if command -q mise
    mise activate fish | source
end

set -g fish_greeting

if not set -q EDITOR
    set -gx EDITOR nvim
end

if not set -q VISUAL
    set -gx VISUAL $EDITOR
end

if not set -q PAGER
    set -gx PAGER less
end

alias ll 'ls -lah'
alias gs 'git status --short --branch'
alias gd 'git diff'
alias gds 'git diff --staged'
alias gl 'git log --oneline --decorate --graph -20'

if command -q nvim
    alias vim nvim
end

if command -q bat
    alias cat bat
end
