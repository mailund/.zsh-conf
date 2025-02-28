if ! [ -d ${ZSH_CONF_PYTHON_VENV} ]; then
    echo "Creating zsh-conf default venv..."
    python3 -m venv ${ZSH_CONF_PYTHON_VENV} || echo "Error creating zsh-conf default venv" 
    echo 'export PYTHONPATH="$HOME/.zsh-conf/python:$PYTHONPATH"' >> ${ZSH_CONF_PYTHON_VENV}/bin/activate
fi
[ -d ${ZSH_CONF_PYTHON} ] || mkdir -p ${ZSH_CONF_PYTHON} || echo "Error creating ${ZSH_CONF_PYTHON}"


update_zsh_python() {
    echo "Updating zsh-conf python packages... (this might take a while)"
    source ${ZSH_CONF_PYTHON_VENV}/bin/activate

    for package in "${ZSH_CONF_PYTHON}"/*; do
        if [ -d "${package}" ] && [ -f "${package}/pyproject.toml" ]; then
            cd "${package}"
            pip install -e . > /dev/null || echo "Error installing $(basename ${package})"
            cd ..
        fi
    done
    unset package
    deactivate
}

_call_python() {
    (
        source "${ZSH_CONF_PYTHON_VENV}/bin/activate"
        eval "$@"
        deactivate
    )
}
