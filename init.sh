# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

ZSH_THEME="minimal"

# Configuring...
zstyle ':omz:update' mode auto      # update automatically without asking
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

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

# Functions
genome_dk_user=mailund
genome_dk_mount_dir=~/GenomeDK
function mount_gdk() {
    local local_dir=$genome_dk_mount_dir
    local remote_dir=${genome_dk_user}@login.genome.au.dk:/home/${genome_dk_user}

    if ! ( [[ -d $local_dir ]] || mkdir $local_dir ); then
        echo "Couldn't create mount dir $local_dir"
        return 2
    fi

    sshfs $remote_dir $local_dir                        \
        -o idmap=none -o uid=$(id -u),gid=$(id -g)      \
        -o allow_other -o umask=077 -o follow_symlinks
}
function unmount_gdk() {
    umount $genome_dk_mount_dir
    rmdir $genome_dk_mount_dir
}

# Aliases
alias idot="dot -Tpng -Gbgcolor=black -Nfontcolor=white -Nfontsize=26 -Efontcolor=white -Efontsize=26 -Ncolor=white -Ecolor=white | kitty icat --align=left"

