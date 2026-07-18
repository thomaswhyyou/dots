# vim: filetype=sh
export EDITOR='vim' VISUAL='vim'
export PAGER='less'

# Aliases (https://natelandau.com/my-mac-osx-bash_profile)
alias ll='ls -FGlAhp'                       # Preferred 'ls' implementation
alias which='type -a'                       # which: Find executables
alias path='echo -e ${PATH//:/\\n}'         # path: Echo all executable Paths
alias ..2='cd ../../'                       # Go back 2 directory levels
alias ..3='cd ../../../'                    # Go back 3 directory levels
alias ..4='cd ../../../../'                 # Go back 4 directory levels
alias ..5='cd ../../../../../'              # Go back 5 directory levels
alias ..6='cd ../../../../../../'           # Go back 6 directory levels

# mise
if [[ -f /opt/homebrew/bin/mise ]]; then
  eval "$(mise activate zsh)"
fi

# ---

# neovim
if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'
  export EDITOR=nvim VISUAL=nvim
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
  alias tls='tmux ls'
  alias tat='tmux attach -d -t'
  alias tns='tmux new-session -s'
  alias tks='tmux kill-session -t'

  # Make sure we detach first if we are already inside tmux.
  if [[ "$TERM" == "tmux-255color" ]]; then
    tmux detach
  fi

  # Set up a default session called 'one' if not exist
  if ! tmux has-session -t one > /dev/null 2>&1; then
    tmux new -s one -n one -d
  fi
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# eza
if command -v eza >/dev/null 2>&1; then
  alias ll='eza --all --long --classify --group-directories-first'
  alias lt='ll --tree --level=3'
fi

# atuin
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# elixir & erlang
export ERL_AFLAGS="-kernel shell_history enabled"
