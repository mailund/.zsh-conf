
for f in *.zsh; do
    [ -f $f ] && [ "$f" != "init.zsh" ] && source $f
done
