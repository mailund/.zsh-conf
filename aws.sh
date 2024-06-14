#!/bin/bash

declare -A ID_NAME_MAP=()
declare -A NAME_ID_MAP=()

ec2_load() {
    local name_pattern="$1"
    local instances=$(
        aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=*$name_pattern*" \
            --query "Reservations[*].Instances[*].[InstanceId, Tags[?Key=='Name'].Value | [0]]" \
            --output text)

    while read -r instance_id instance_name; do
        ID_NAME_MAP[$instance_id]=$instance_name
        NAME_ID_MAP[$instance_name]=$instance_id
    done <<< $instances
}

# Main function to handle subcommands
maws() {
    local pattern="Mailund" # look for instances with this pattern
    while getopts ":p:" opt; do
        case ${opt} in
            p)
            pattern=$OPTARG
            ;;
            *)
            usage
            ;;
        esac
    done
    shift $((OPTIND -1))

    ec2_load $pattern

    case "$1" in
        list)
            shift
            ec2_list "$@"
            ;;

        start)
            shift
            ec2_start "$@"
            ;;

        stop)
            shift
            ec2_stop "$@"
            ;;

        status)
            shift
            ec2_status "$@"            
            ;;
                    
            *)
            echo "Usage: $0 {list|start|stop|status} [arguments]"
            return 1
    esac
}

# Subcommand to list instances with a specific name pattern and build the ID-Name map
ec2_list() {
    # Calculate column widths
    local max_name_length=$(col_width ${(@k)NAME_ID_MAP})
    local max_id_length=$(col_width ${(@v)NAME_ID_MAP})

    local format="%-${max_name_length}s %-$(($max_id_length))s\n"

    # Print the header
    printf "$format" "Name" "Instance ID"

    # Print the separator
    printf "%-${max_name_length}s %-${max_id_length}s %s\n" \
        "$(repeat_char $max_name_length '-')" \
        "$(repeat_char $max_id_length '-')" 

    # Print the rows
    for key val in "${(@kv)NAME_ID_MAP}"; do
        printf "$format" "$key" "$val"
    done
}

# Subcommand to start instances by name
ec2_start() {
    local names=("$@")
    local instance_ids=()

    # Take default names if none are provided
    if [ ${#names[@]} -eq 0 ]; then
        names=(${(k)NAME_ID_MAP})
    fi

    for name in "${names[@]}"; do
        instance_ids+=("${NAME_ID_MAP[$name]}")
    done

    aws ec2 start-instances --instance-ids ${instance_ids}
}

# Subcommand to stop instances by name
ec2_stop() {
    local names=("$@")
    local instance_ids=()

    # Take default names if none are provided
    if [ ${#names[@]} -eq 0 ]; then
        names=(${(k)NAME_ID_MAP})
    fi

    for name in "${names[@]}"; do
        instance_ids+=("${NAME_ID_MAP[$name]}")
    done

    aws ec2 stop-instances --instance-ids ${instance_ids}
}

ec2_status() {
    local names=("$@")
    local instance_ids=()

    # Take default names if none are provided
    if [ ${#names[@]} -eq 0 ]; then
        names=(${(k)NAME_ID_MAP})
    fi

    # Get the instance IDs for the names
    for name in "${names[@]}"; do
        instance_ids+=("${NAME_ID_MAP[$name]}")
    done

    local stats=$(
        aws ec2 describe-instances \
            --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value | [0], InstanceId, State.Name]" \
            --output text \
            --instance-ids ${instance_ids}
    )

    if [ $? -ne 0 ]; then
        echo "Error fetching instance statuses: $stats"
        return 1
    fi

    # Initialize associative arrays
    typeset -A NAME_TO_ID
    typeset -A NAME_TO_STATUS

    # Parse stats and populate associative arrays
    local line
    while IFS=$'\t' read -r name instance_id state; do
        NAME_TO_ID[$name]=$instance_id
        NAME_TO_STATUS[$name]=$state
    done <<< "$stats"

    # Print the associative arrays for verification
    print_formatted_table NAME_TO_ID NAME_TO_STATUS
}

print_formatted_table() {
    local ids=${(@k)NAME_TO_ID}
    local states=${(@k)NAME_TO_STATUS}

    # Calculate column widths
    local max_name_length=$(col_width ${(@k)NAME_TO_ID})
    local max_id_length=$(col_width ${(@v)NAME_TO_ID})
    local max_status_length=$(col_width ${(@v)NAME_TO_STATUS})

    local format="%-${max_name_length}s %-$(($max_id_length))s %s\n"

    # Print the header
    printf "$format" "Name" "Instance ID" "State"

    # Print the separator
    printf "%-${max_name_length}s %-${max_id_length}s %s\n" \
        "$(repeat_char $max_name_length '-')" \
        "$(repeat_char $max_id_length '-')" \
        "$(repeat_char $max_status_length '-')" 

    # Print the rows
    for name in ${(k)NAME_TO_ID}; do
        printf "$format" "$name" "${NAME_TO_ID[$name]}" $(state_col "${NAME_TO_STATUS[$name]}")
    done
}

col_width() {
    local max=0
    for val in "$@"; do
        if (( ${#val} > max )); then
            max=${#val}
        fi
    done
    echo $max
}

repeat_char() {
    local count=$1
    local char=${2:-'-'}
    printf "%${count}s" | tr ' ' "$char"
}

state_col() {
    local state=$1
    case $state in
        running)
            echo "\e[32m$state\e[0m"
            ;;
        stopped)
            echo "\e[31m$state\e[0m"
            ;;
        *)
            echo "\e[90m$state\e[0m"
            ;;
    esac
}