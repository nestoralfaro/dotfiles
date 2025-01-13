alias vim="nvim"
# bindkey -v
bindkey -v '^?' backward-delete-char # to backspace when switching to insert mode
# PROMPT='%B%F{33}%*%f%b '
PROMPT='%B%F{33}>%f%b '
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# syntax highlighting; should be last
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
