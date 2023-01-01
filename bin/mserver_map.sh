#!/bin/bash

. $(dirname $0)/common.sh
check_running_as_minecraft

usage() { echo "Usage: $0 [-n <name>] [-o output directory]" 1>&2; exit 1; }

while getopts ":n:o:" o; do
    case "${o}" in
        n)
            NAME=${OPTARG}
            ;;
        o)
            OUTPUT_DIR=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${NAME}" ] || [ -z "${OUTPUT_DIR}" ]; then
    usage
fi

if [ ! -e $WORLDS_DIR/$NAME ]; then
    echo "$WORLDS_DIR/$NAME doesn't exist.  Exiting..."
    exit 1
fi

REAL_OUTPUT_DIR=${OUTPUT_DIR}/$NAME
mkdir -p "${REAL_OUTPUT_DIR}"

# mcmap
if [ -e $MCMAP ]; then
    echo "Running mcmap..."

    mkdir -p "${REAL_OUTPUT_DIR}/mcmap/output"

    echo "Generating image for $NAME..."
    $MCMAP -file $REAL_OUTPUT_DIR/mcmap/output.png $WORLDS_DIR/$NAME/world

    echo "Generating map for $NAME..."
    $MCMAP -tile 256 -file $REAL_OUTPUT_DIR/mcmap/output $WORLDS_DIR/$NAME/world

    echo "Finishing up mcmap..."
    cp $HTTP_TEMPLATE_DIR/index-mcmap.html $REAL_OUTPUT_DIR/mcmap/index.html
fi

# unmined
if [ -e $UNMINED ]; then
    echo "Running unmined..."

    mkdir -p "${REAL_OUTPUT_DIR}/unmined"

    $UNMINED web render --world $WORLDS_DIR/$NAME/world \
	     --dimension overworld \
	     --output $REAL_OUTPUT_DIR/unmined \
	     --zoomin 3 --zoomout 4
fi

# Generate the index.html and the world list
cp $HTTP_TEMPLATE_DIR/index.html $OUTPUT_DIR/index.html

WORLDS_JSON_FILE=$OUTPUT_DIR/worlds.json

WORLD_JSON='{}'
while read l; do
    DIR_WORLD_NAME=$(basename $l)
    WORLD_JSON=$(echo "$WORLD_JSON" | jq ". + { \"$DIR_WORLD_NAME\": {}}")
done <<<$(ls -d -1 $OUTPUT_DIR/*/ | sort)
echo "$WORLD_JSON" >$WORLDS_JSON_FILE

echo "Now put $REAL_OUTPUT_DIR behind an http server."
