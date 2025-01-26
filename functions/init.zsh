
for f in *.zsh; do
    if [ "$f" = "init.zsh" ]; then
        continue
    fi
    source $f
done
