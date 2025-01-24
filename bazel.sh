show_bazel_deps() {
    local target=$1
    shift
    local tags=""
    local output_format=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --package ) tags="package"; shift ;;
            --module ) tags="(package|module)"; shift ;;
            --graph ) output_format="--output graph"; shift ;;
            -- ) shift; break ;;
            * ) break ;;
        esac
    done

    local query="deps(${target})"
    if [[ -n $tags ]]; then
        query="attr(tags, \"${tags}\", //...) intersect ${query}"
    fi
    local cmd="bazel query '${query}' --noimplicit_deps ${output_format}"
    eval "$cmd"
}