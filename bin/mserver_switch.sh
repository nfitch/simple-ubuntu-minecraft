#!/bin/bash

. $(dirname $0)/common.sh
check_running_as_minecraft

usage() { echo "Usage: $0 [-n <name>]" 1>&2; exit 1; }

while getopts ":n:" o; do
    case "${o}" in
        n)
            NAME=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${NAME}" ]; then
    usage
fi

if [ ! -e $WORLDS_DIR/$NAME ]; then
    echo "Cannot switch to world $NAME, $WORLDS_DIR/$NAME does not exist."
    exit 1
fi

minecraft_is_running
if [ $? == 1 ]; then
    echo "Minecraft is already running.  Stop the server, then switch."
    exit 1
fi

setup_dirs
read_rcon_password
cp $SYSTEMD_TEMPLATE_DIR/* $SYSTEMD_DIR/.
# Replacements in minecraft
sed -i -e "s#REPLACE_MSERVER_WORLD#$NAME#g" $SYSTEMD_VARS_FILE
sed -i -e "s#REPLACE_RCON_PASSWORD#$RCON_PASSWORD#g" $SYSTEMD_VARS_FILE
# Replacements in minecraft.service
WORKING_DIRECTORY=$WORLDS_DIR/$NAME
sed -i -e "s#REPLACE_MSERVER_WORLD_DIRECTORY#$WORKING_DIRECTORY#g" $SYSTEMD_SERVICE_FILE
sed -i -e "s#REPLACE_MSERVER_TOOLS_DIRECTORY#$TOOLS_DIR#g" $SYSTEMD_SERVICE_FILE

# Reload the systemd files we just changed
systemctl daemon-reload

exit 0
