
git -C ${ZSH_CONF_HOME} fetch
# Check if the local repository is behind the remote
if ! git -C ${ZSH_CONF_HOME} diff --quiet HEAD..origin/$(git -C ${ZSH_CONF_HOME} rev-parse --abbrev-ref HEAD); then
    echo "Updates to zhs-conf available. Running git pull..."
    git -C ${ZSH_CONF_HOME} pull
fi