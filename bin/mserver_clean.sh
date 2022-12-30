#!/bin/bash

. $(dirname $0)/common.sh
check_running_as_minecraft

usage() {
    echo "Usage: $0 [-a NO]" 1>&2;
    echo "\
This will erase all of your worlds from this host. \
You really don't want to do this. \
\
If you really, really do, run with -a YES."
    exit 1;
}

while getopts ":a:" o; do
    case "${o}" in
        a)
            ANSWER=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${ANSWER}" ] || [ "${ANSWER}" != "YES" ]; then
    usage
fi

echo "Cleaning everything up..."
rm -rf $WORLDS_DIR/*
rm -rf $SYSTEMD_DIR/*
exit 0;
