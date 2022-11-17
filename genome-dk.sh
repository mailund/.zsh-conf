
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
