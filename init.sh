
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
    # This one has to go last
    zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

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

# Determines prompt modifier if and when a conda environment is active
conda config --set changeps1 False
precmd_conda_info() {
  if [[ -n $CONDA_PREFIX ]]; then
      if [[ $(basename $CONDA_PREFIX) == "anaconda3" ]]; then
        # Without this, it would display conda version
        CONDA_ENV="@base "
      else
        # For all environments that aren't (base)
        CONDA_ENV="@$(basename $CONDA_PREFIX) "
      fi
  # When no conda environment is active, don't show anything
  else
    CONDA_ENV=""
  fi
}

# Run the previously defined function before each prompt
precmd_functions+=( precmd_conda_info )

# Allow substitutions and expansions in the prompt
setopt prompt_subst
autoload -U colors && colors
PROMPT='%F{cyan}%2~%F{reset} $(vcs_status) %F{141}$CONDA_ENV%F{reset}'$'\n''»%b '
