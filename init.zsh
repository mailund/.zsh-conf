
ZSH_CONF_HOME=~/.zsh-conf
ZSH_CONF_PYTHON_VENV=~/.zsh-conf-venv
ZSH_CONF_PYTHON=$ZSH_CONF_HOME/python

# Update zsh-conf installation
source $ZSH_CONF_HOME/init/update_zsh_conf.zsh
source $ZSH_CONF_HOME/init/update_python_venv.zsh
source $ZSH_CONF_HOME/init/update_plugins.zsh

_runindir() { 
    mydir=$(pwd)
    cd -- "$1" && shift && eval " $@"
    cd -- "$mydir"
 }
 _init_dir() {
    _runindir $1 source init.zsh
 }

# Setup zsh-conf functions
fpath=(
    ${ZSH_CONF_HOME}/functions
    "${fpath[@]}"
)
autoload -U $fpath[1]/*(.:t)


# And get aliases
source $ZSH_CONF_HOME/alias.zsh

# Setting plugins...
zstyle :omz:plugins:iterm2 shell-integration yes
plugins=(
    git
    iterm2

    # This one has to go last
    zsh-syntax-highlighting
)


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

