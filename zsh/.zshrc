HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# abbr saves by mv-ing a temp file over this path, so point it past the dotfiles symlink
ABBR_USER_ABBREVIATIONS_FILE=$HOME/.config/zsh-abbr/user-abbreviations
ABBR_USER_ABBREVIATIONS_FILE=${ABBR_USER_ABBREVIATIONS_FILE:A}
source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh

autoload -U promptinit; promptinit
prompt pure

eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"
eval "$(mise activate zsh)"

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

alias ls='eza -h --git --icons'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias llt='ls -lT'
alias li='timg -pk --title'

# git fetch -ap してから switch する。ブランチを省略したら fzf で選ぶ
gs() {
  git fetch -ap || return
  local branch=$1
  if [[ -z $branch ]]; then
    branch=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes \
      | sed 's#^origin/##' | grep -vx -e HEAD -e origin | sort -u \
      | fzf --prompt='switch> ') || return
  fi
  git switch "$branch"
}
compdef _git gs=git-switch

# ほかのプラグインより後に読む必要がある
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
