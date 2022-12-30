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

setup_dirs
mkdir -p $WORLDS_DIR/$NAME

# Download server.jar
# https://gaming.stackexchange.com/questions/123194/is-there-a-way-to-get-the-latest-server-jar-through-a-url-that-doesnt-change
curl -s $MINECRAFT_VERSION_MANIFEST |
    jq .versions[0].url | xargs curl -s |
    jq .downloads.server.url |
    xargs curl -o $WORLDS_DIR/$NAME/server.jar

cp -r $MINECRAFT_TEMPLATE_DIR/* $WORLDS_DIR/$NAME/.

# Replace the rcon password for the server
read_rcon_password
sed -i -e "s#REPLACE_RCON_PASSWORD#$RCON_PASSWORD#g" $WORLDS_DIR/$NAME/server.properties
