
_runindir() { 
    mydir=$(pwd)
    cd -- "$1" && shift && eval " $@"
    cd -- "$mydir"
 }
 _init_dir() {
    mydir=$(pwd)
    cd $1
    source init.zsh
    cd $mydir
 }

_update_zsh_conf() {
    git fetch
    # Check if the local repository is behind the remote
    if ! git diff --quiet HEAD..origin/$(git rev-parse --abbrev-ref HEAD); then
        echo "Updates to zhs-conf available. Running git pull..."
        git pull
    fi
}

# # Updating .zsh-conf
_runindir ~/.zsh-conf _update_zsh_conf

# # Handle plugins and functions
_init_dir ~/.zsh-conf/plugins

# I don't fucking understand why the _init_dir doesn't work for maws
mydir=$(pwd)
    cd ~/.zsh-conf/functions/
    source init.zsh
cd $mydir
# source ~/.zsh-conf/functions/aws.zsh
# _runindir ~/.zsh-conf/functions source init.zsh

## Alias for displaying dot files in iTerm
alias idot="dot -Tpng -Gbgcolor=black -Nfontcolor=white -Nfontsize=26 -Efontcolor=white -Efontsize=26 -Ncolor=white -Ecolor=white | imgcat"

# Configuring...
zstyle ':omz:update' mode auto      # update automatically without asking
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Set bat as default pager and set its theme
export PAGER=bat
export BAT_THEME=zenburn

# Theme
ZSH_THEME="af-magic"
source $ZSH/oh-my-zsh.sh

