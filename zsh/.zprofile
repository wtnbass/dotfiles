eval "$(/opt/homebrew/bin/brew shellenv zsh)"

typeset -U path
path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  $PNPM_HOME/bin
  $path
)

