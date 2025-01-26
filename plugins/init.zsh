mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/completion 
fpath[1,0]=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/completion
mkdir -p ~/.zsh/cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Downloading plugins
if ! [ -d $ZSH/custom/plugins/zsh-syntax-highlighting ]; then
    echo "Downloading zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if ! [ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/completion/bazel ]; then
    echo "Downloading bazel plugin..."
    curl -o ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/completion/bazel \
        https://raw.githubusercontent.com/bazelbuild/bazel/master/scripts/zsh_completion/_bazel
fi


# Setting plugins...
plugins=(
    bazel
    brew
    git
    github
    iterm2
    virtualenv

    # This one has to go last
    zsh-syntax-highlighting
)
