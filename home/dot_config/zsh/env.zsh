export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-$EDITOR}
export PAGER=${PAGER:-less}
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4,header:#f5c2e7,hl:#f38ba8,hl+:#f38ba8,info:#cba6f7,marker:#a6e3a1,pointer:#f5c2e7,prompt:#cba6f7,spinner:#f5c2e7,border:#6c7086'

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

export PATH
