alias vim="nvim"
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
