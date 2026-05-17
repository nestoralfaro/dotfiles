# export CUBEB_BACKEND=alsa # alsa audio for librewolf. Setting up this env var is a blur. Not sure if i actually need it (or what it does)
alias vim="nvim"
KEYTIMEOUT=1
# bindkey -v
bindkey -v '^?' backward-delete-char # to backspace when switching to insert mode
# PROMPT='%B%F{33}%*%f%b '
# PROMPT='%B%F{33}>%f%b '
NEWLINE=$'\n'
PROMPT="%B%F{14}%*@%n:%f%F{33}%~${NEWLINE}>%f%b "
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# syntax highlighting; should be last
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # macos
# source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # redhat (linux)
