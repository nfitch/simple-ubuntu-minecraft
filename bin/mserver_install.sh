#!/bin/bash

. $(dirname $0)/common.sh
check_running_as_root

usage() { echo "Usage: $0" 1>&2; exit 1; }

while getopts ":" o; do
    case "${o}" in
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Create the minecraft user/group
getent group minecraft
if [ $? != 0 ]; then
    sudo adduser --group minecraft
fi
id minecraft
if [ $? != 0 ]; then
    sudo adduser --no-create-home --ingroup minecraft --disabled-password --disabled-login minecraft
fi

# Setup the dirs
setup_dirs
chown minecraft:minecraft $WORLDS_DIR
chown minecraft:minecraft $SYSTEMD_DIR

# Link up to systemd places
sudo ln -s $SYSTEMD_VARS_FILE /etc/minecraft
sudo ln -s $SYSTEMD_SERVICE_FILE /etc/systemd/system/minecraft.service

# Set up RCON
if [ ! -e $RCON ]; then
    mkdir -p $TOOLS_DIR
    cd $TOOLS_DIR && git clone https://github.com/Tiiffi/mcrcon.git
    cd mcrcon && gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o mcrcon mcrcon.c
    if [ $? != 0 ]; then
	echo "Unable to checkout, compile mcrcon.  You may have to do it manually."
	echo "Check out the README."
	echo "Once you have it working at $RCON rerun install."
	exit 1
    fi
fi

# Generate the rcon password for this server
generate_rcon_password
