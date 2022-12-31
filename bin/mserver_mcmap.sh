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

mkdir -p "${REAL_OUTPUT_DIR}/output"

echo "Generating map..."
$MCMAP -tile 256 -file $REAL_OUTPUT_DIR/output $WORLDS_DIR/$NAME/world

echo "Finishing up..."
cp $HTTP_TEMPLATE_DIR/index-map.html $REAL_OUTPUT_DIR/index.html

echo "Now put $REAL_OUTPUT_DIR behind an http server."
