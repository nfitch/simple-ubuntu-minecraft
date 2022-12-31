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

minecraft_is_running
if [ $? == 0 ]; then
    echo "We don't think Minecraft is running... but we'll try anyways..."
fi

read_rcon_password
$RCON -p "$RCON_PASSWORD"
