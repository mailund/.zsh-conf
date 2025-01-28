
_runindir() { 
    mydir=$(pwd)
    cd -- "$1" && shift && eval " $@"
    cd -- "$mydir"
 }
 _init_dir() {
    _runindir $1 source init.zsh
 }

_update_zsh_conf() {
    git fetch
    # Check if the local repository is behind the remote
    if ! git diff --quiet HEAD..origin/$(git rev-parse --abbrev-ref HEAD); then
        echo "Updates to zhs-conf available. Running git pull..."
        git pull
    fi
}

_get_default_venv() {
    if ! [ -d "$HOME/.zsh-conf-venv" ]; then
        echo "Creating default venv..."
        python3 -m venv "$HOME/.zsh-conf-venv"
    fi
}
_call_python() {
    "$HOME/.zsh-conf-venv/bin/python" "$@"
}

# # Updating .zsh-conf
_runindir ~/.zsh-conf _update_zsh_conf

# Update Python venv
_get_default_venv

# # Handle plugins and functions
_init_dir ~/.zsh-conf/plugins
_init_dir ~/.zsh-conf/functions


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

