# Downloading plugins
if ! [ -d $ZSH/custom/plugins/zsh-syntax-highlighting ]; then
    echo "Downloading zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Setting plugins...
plugins=(
    brew
    git
    github
    iterm2
    virtualenv

    # This one has to go last
    zsh-syntax-highlighting
)
