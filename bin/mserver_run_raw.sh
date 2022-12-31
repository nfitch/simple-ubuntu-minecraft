#!/bin/bash

. $(dirname $0)/common.sh
check_running_as_minecraft

usage() {
    echo "Usage: $0 [-n <name>] [-p port] [-r rcon_port]" 1>&2;
    echo "The default minecraft/rcon ports are 25565/25575" 1>&2;
    echo "Recommendation: -p 25585 -r 25595" 1>&2;
    exit 1;
}

while getopts ":n:p:r:" o; do
    case "${o}" in
	n)
	    RAW_NAME=${OPTARG}
	    ;;
	p)
	    PORT=${OPTARG}
	    ;;
	r)
	    RCON_PORT=${OPTARG}
	    ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${RAW_NAME}" ] || [ -z "${PORT}" ] || [ -z "${RCON_PORT}" ]; then
    usage
fi

if [ "${PORT}" -eq "${DEFAULT_MINECRAFT_PORT}" ] ||
       [ "${RCON_PORT}" -eq "${DEFAULT_RCON_PORT}" ]; then
    echo "The default minecraft/rcon ports are 25565/25575.  Pick other ports.\n" 1>&2;
    usage
fi

# Check if there is a world selected
read_selected_name
if [ "${NAME}" = "${RAW_NAME}" ]; then
    echo "You can't run the selected world ($NAME) raw.  Exiting..."
    exit 1
fi

# Check to make sure the world directory is there
if [ ! -e $WORLDS_DIR/$RAW_NAME ]; then
    echo "World $RAW_NAME ($WORLDS_DIR/$RAW_NAME) does not exist.  Exiting..."
    exit 1
fi

# Search for and modify the server.properties
SERVER_PROPERTIES_FILE=$WORLDS_DIR/$RAW_NAME/server.properties
if [ ! -e $SERVER_PROPERTIES_FILE ]; then
    echo "Can't locate the server.properties file at $SERVER_PROPERTIES_FILE.  Exiting..."
    exit 1
fi

sed -i -e "s#query.port=[0-9]*#query.port=$PORT#g" $SERVER_PROPERTIES_FILE
sed -i -e "s#server-port=[0-9]*#server-port=$PORT#g" $SERVER_PROPERTIES_FILE
sed -i -e "s#rcon.port=[0-9]*#rcon.port=$RCON_PORT#g" $SERVER_PROPERTIES_FILE

# Ok, start it up
echo "Starting $RAW_NAME from $WORLDS_DIR/$RAW_NAME..."
cd $WORLDS_DIR/$RAW_NAME && /usr/bin/java -Xms2G -Xmx4G -XX:ParallelGCThreads=6 -jar server.jar --nogui
cd -
