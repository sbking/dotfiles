if not contains -- "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
end

if command -q mise
    mise activate fish | source
end

set -g fish_greeting

if command -q starship
    starship init fish | source
end

if not set -q EDITOR
    set -gx EDITOR nvim
end

if not set -q VISUAL
    set -gx VISUAL $EDITOR
end

if not set -q PAGER
    set -gx PAGER less
end

set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --color=bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4,header:#f5c2e7,hl:#f38ba8,hl+:#f38ba8,info:#cba6f7,marker:#a6e3a1,pointer:#f5c2e7,prompt:#cba6f7,spinner:#f5c2e7,border:#6c7086"

if command -q fzf
    fzf --fish | source
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
