HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt INC_APPEND_HISTORY # add commands as they're entered
setopt SHARE_HISTORY # share across sessions
setopt HIST_FIND_NO_DUPS # fzf Ctrl+r won't show duplicates

# export CUBEB_BACKEND=alsa # alsa audio for librewolf. Setting up this env var is a blur. Not sure if i actually need it (or what it does)
alias vim="nvim"
export EDITOR=vi
export VISUAL=vi
alias sudo="sudo EDITOR=vi"
KEYTIMEOUT=1
# bindkey -v
bindkey -v '^?' backward-delete-char # to backspace when switching to insert mode
# PROMPT='%B%F{33}%*%f%b '
# PROMPT='%B%F{33}>%f%b '
NEWLINE=$'\n'
PROMPT="%B%F{14}%*@%n:%f%F{33}%~${NEWLINE}>%f%b "
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
# after `source <(fzf --zsh)`, override the history widget
__fzf_history__() {
  local selected
  if selected=$(fc -rl 1 | fzf +s --tac --tiebreak=index --query="$LBUFFER"); then
    LBUFFER="${selected##*[[:digit:]:]  }"
  fi
  zle reset-prompt
}
zle -N __fzf_history__
bindkey '^R' __fzf_history__

# syntax highlighting; should be last
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # macos
# source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # redhat (linux)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh # (brew|apt|emerge) install zsh-autosuggestions
# source ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh # gentoo: git clone https://github.com/zsh-users/zsh-autosuggestions.git
bindkey '^ ' autosuggest-accept
bindkey '^w' forward-word
