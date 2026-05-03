export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-$EDITOR}
export PAGER=${PAGER:-less}

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

export PATH
