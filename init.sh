
# Update this configuration before we continue...
if [ ! -d ~/.zsh-conf ]; then
    echo "Please clone this repo to ~/.zsh-conf"
    exit 1
else
    original_dir=$(pwd)
    cd /Users/mailund/.zsh-conf || exit
    git fetch

    # Check if the local repository is behind the remote
    if ! git diff --quiet HEAD..origin/$(git rev-parse --abbrev-ref HEAD); then
        echo "Updates to zhs-conf available. Running git pull..."
        git pull
    fi
    cd "$original_dir"
fi

# Configuring...
zstyle ':omz:update' mode auto      # update automatically without asking
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Theme
# Right now, I overwrite it at the bottom
ZSH_THEME="minimal"



# Setting plugins...
plugins=(
    brew
    poetry
    git
    github
    iterm2
    virtualenv
    # This one has to go last
    zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# Loading AWS stuff
source ~/.zsh-conf/aws.sh

# Load bazel functions
source ~/.zsh-conf/bazel.sh

# Loading other configurations
source ~/.zsh-conf/functions.sh
source ~/.zsh-conf/alias.sh

# Set bat as default pager and set its theme
export PAGER=bat
export BAT_THEME=zenburn


## Overwriting the prompt
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}[%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}●%{$fg[red]%}%{$reset_color%}] "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}] "
ZSH_THEME_SVN_PROMPT_PREFIX=$ZSH_THEME_GIT_PROMPT_PREFIX
ZSH_THEME_SVN_PROMPT_SUFFIX=$ZSH_THEME_GIT_PROMPT_SUFFIX
ZSH_THEME_SVN_PROMPT_DIRTY=$ZSH_THEME_GIT_PROMPT_DIRTY
ZSH_THEME_SVN_PROMPT_CLEAN=$ZSH_THEME_GIT_PROMPT_CLEAN
ZSH_THEME_HG_PROMPT_PREFIX=$ZSH_THEME_GIT_PROMPT_PREFIX
ZSH_THEME_HG_PROMPT_SUFFIX=$ZSH_THEME_GIT_PROMPT_SUFFIX
ZSH_THEME_HG_PROMPT_DIRTY=$ZSH_THEME_GIT_PROMPT_DIRTY
ZSH_THEME_HG_PROMPT_CLEAN=$ZSH_THEME_GIT_PROMPT_CLEAN

vcs_status() {
    if [[ $(whence in_svn) != "" ]] && in_svn; then
        svn_prompt_info
    elif [[ $(whence in_hg) != "" ]] && in_hg; then
        hg_prompt_info
    else
        git_prompt_info
    fi
}

# Python venv
function virtualenv_info { 
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}
