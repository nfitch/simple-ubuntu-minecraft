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
if [ $? == 1 ]; then
    echo "Minecraft is already running."
    exit 1    
fi

# Check if there is a world selected
read_selected_name
if [ "${NAME}" = "" ]; then
    echo "No world selected.  Use mserver_switch to select a world."
    exit 1
fi

# Check to make sure the world directory is there (this really is a double check)
if [ ! -e $WORLDS_DIR/$NAME ]; then
    echo "Cannot switch to world $NAME, $WORLDS_DIR/$NAME does not exist."
    exit 1
fi

# Ok, start it up
echo "Starting $NAME from $WORLD_DIR..."
systemctl start minecraft.service

echo "Use this command to check the status of the server:"
echo "systemctl status minecraft.service"
