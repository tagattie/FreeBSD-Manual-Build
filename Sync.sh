#! /bin/sh

export LANG=C
export PATH=/usr/local/bin:/usr/bin:/bin

CMDNAME=$(basename "$0")

RSYNC_FLAGS="-vaz --delete --stats"

while getopts ?h:son OPT; do
    case ${OPT} in
        "?")
            echo "Usage: ${CMDNAME} [-?|-h hostname [-s|-o]] [-n]"
            echo "  -?: Show this message."
            echo "  -h: Hostname of sync destination."
            echo "  -s: Sync src directory."
            echo "  -o: Sync obj directory."
            echo "  -n: Dry run."
            exit 0 ;;
        "h")
            HOSTNAME=${OPTARG}
            KERNCONF=$(echo ${HOSTNAME} | tr a-z A-Z) ;;
        "s")
            SYNC_DIR=src ;;
        "o")
            SYNC_DIR=obj ;;
        "n")
            RSYNC_FLAGS="-n ${RSYNC_FLAGS}" ;;
    esac
done

if [ -z "${HOSTNAME}" ]; then
    echo "Error: You must specify hostname of sync destination."
    exit 1
fi

if [ -z "${SYNC_DIR}" ]; then
    echo "Error: You must specify either one of -s or -o."
    exit 1
fi

SYNC_FROM_DIRS=/usr/${SYNC_DIR}/
SYNC_TO_DIR=:/usr/${SYNC_DIR}

rsync ${RSYNC_FLAGS} \
      --exclude="/.svn" \
      --exclude="/arm.armv6" \
      --exclude="/arm64.aarch64" \
      --exclude="/i386.i386" \
      --exclude="/mips.mips*" \
      --include="/usr/src/sys/boot" \
      --include="/usr/src/sys/${KERNCONF}" \
      --exclude="/usr/src/sys/*" \
      --exclude="/var" \
      ${SYNC_FROM_DIRS} ${HOSTNAME}${SYNC_TO_DIR}
