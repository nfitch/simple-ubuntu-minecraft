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

# Check if minecraft is already running
minecraft_is_running
if [ $? == 0 ]; then
    echo "Minecraft isn't running."
    exit 1    
fi

systemctl status minecraft
