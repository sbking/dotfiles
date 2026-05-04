zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
zsh_compdump=

if mkdir -p "$zsh_cache_dir" 2>/dev/null; then
  zsh_compdump="$zsh_cache_dir/zcompdump"
fi

for completions_dir in \
  /opt/homebrew/share/zsh/site-functions \
  /usr/local/share/zsh/site-functions \
  "$HOME/.local/share/zsh/site-functions"
do
  if [ -d "$completions_dir" ]; then
    fpath=("$completions_dir" $fpath)
  fi
done
unset completions_dir

autoload -Uz compinit
if [ -n "$zsh_compdump" ]; then
  compinit -d "$zsh_compdump"
else
  compinit
fi
unset zsh_cache_dir zsh_compdump
