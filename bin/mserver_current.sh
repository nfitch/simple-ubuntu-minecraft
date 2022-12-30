#!/bin/bash

. $(dirname $0)/common.sh
check_running_as_minecraft

usage() { echo "Usage: $0" 1>&2; exit 1; }

while getopts ":" o; do
    case "${o}" in
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

read_selected_name
if [ "${NAME}" = "" ]; then
    echo "No world selected.  Use mserver_switch to select a world."
    exit 1
fi

echo ${NAME}
