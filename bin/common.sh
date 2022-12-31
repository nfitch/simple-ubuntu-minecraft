#!/bin/bash

# Common Variables
ROOT_DIR=$(dirname $(dirname $(realpath ${BASH_SOURCE:-$0})))
SYSTEMD_TEMPLATE_DIR=$ROOT_DIR/template-systemd
MINECRAFT_TEMPLATE_DIR=$ROOT_DIR/template-minecraft
WORLDS_DIR=$ROOT_DIR/worlds
SYSTEMD_DIR=$ROOT_DIR/systemd
TOOLS_DIR=$ROOT_DIR/tools
SYSTEMD_VARS_FILE=$SYSTEMD_DIR/minecraft
SYSTEMD_SERVICE_FILE=$SYSTEMD_DIR/minecraft.service
RCON_PASSWORD_FILE=$SYSTEMD_DIR/rcon.password
RCON=$TOOLS_DIR/mcrcon/mcrcon
MCMAP=$TOOLS_DIR/mcmap/build/bin/mcmap
MINECRAFT_VERSION_MANIFEST=https://launchermeta.mojang.com/mc/game/version_manifest.json

# Common Functions
function setup_dirs() {
    mkdir -p $WORLDS_DIR
    mkdir -p $SYSTEMD_DIR
}

function minecraft_is_running() {
    systemctl is-active --quiet minecraft
    if [ $? = 0 ]; then
	return 1;
    fi
    return 0;
}

function read_selected_name() {
    NAME=$(grep 'MSERVER_WORLD=' $SYSTEMD_VARS_FILE | cut -d '=' -f 2)
    if [ "${NAME}" != "" ]; then
	WORLD_DIR=$WORLDS_DIR/$NAME
    fi
}

function generate_rcon_password() {
    if [ ! -e $RCON_PASSWORD_FILE ]; then
	cat /dev/urandom | tr -dc _A-Z-a-z-0-9 | head -c${1:-32} >$RCON_PASSWORD_FILE
	chown minecraft:minecraft $RCON_PASSWORD_FILE
    fi
}

function read_rcon_password() {
    RCON_PASSWORD=$(cat $RCON_PASSWORD_FILE)
    if [ "${RCON_PASSWORD}" = "" ]; then
	echo "No rcon password found.  Exiting..."
	exit 1
    fi
}

function check_running_as_root () {
    if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
    fi
}

function check_running_as_minecraft () {
    if [ "$(whoami)" != "minecraft" ]; then
	echo "Script must be run as user: minecraft"
	exit 1
    fi
}
