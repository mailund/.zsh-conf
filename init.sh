
# Configuring...
zstyle ':omz:update' mode auto      # update automatically without asking
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Theme
ZSH_THEME="minimal"

# Setting plugins...
plugins=(
    brew
    git
    github
    iterm2
    vscode
    z
    # This one has to go last
    zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# Loading other configurations
# source ~/.zsh-conf/genome-dk.sh
source ~/.zsh-conf/functions.sh
source ~/.zsh-conf/alias.sh
