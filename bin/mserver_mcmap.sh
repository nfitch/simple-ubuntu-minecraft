#!/bin/bash

. $(dirname $0)/common.sh
check_running_as_minecraft

usage() { echo "Usage: $0 [-n <name>]" 1>&2; exit 1; }

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

mkdir -p "${OUTPUT_DIR}"

echo $MCMAP -tile 256 -file $OUTPUT_DIR $WORLDS_DIR/$NAME/world
