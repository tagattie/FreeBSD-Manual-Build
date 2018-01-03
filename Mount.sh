#! /bin/sh -xe

export LANG=C
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

CMDNAME=$(basename $0)
CONFDIR=$(pwd)/conf

MOUNT=0
UNMOUNT=0
CHECK=0

print_usage() {
    echo "Usage: ${CMDNAME} -?|-h hostname -m|-u|-c"
    echo "Options:"
    echo "  -?: Show this message."
    echo "  -h: Target hostname."
    echo "  -m: Mount targets."
    echo "  -u: Unmount targets."
    echo "  -c: Check if targets are mounted."
    exit 0
}

mount_targets() {
    for i in ${MOUNT_TARGETS}; do
        host=$(echo ${i}|awk -F':' '{print $1}')
        dir=$(echo ${i}|awk -F':' '{print $2}')
        if [ "${dir}" == "/NFSRoot" ] || \
               [ "${dir}" == "/TFTPBoot" ]; then
            dir=
        fi
        fstype=$(echo ${i}|awk -F':' '{print $3}')
        destbase=$(echo ${i}|awk -F':' '{print $4}')
        echo "${CMDNAME}: Mounting ${i}..."
        mount -t ${fstype} ${host}:${dir} ${destbase}${dir}
    done
    return 0
}

unmount_targets() {
    for i in ${UNMOUNT_TARGETS}; do
        echo "${CMDNAME}: Unmounting ${i}..."
        umount ${i} || ESTATUS=$?
    done
    return 0
}

setup_target_vars() {
    MOUNTED_TARGETS=$(for i in ${MOUNT_TARGETS}; do
                          dir=$(echo ${i}|awk -F':' '{print $2}')
                          if [ "${dir}" == "/NFSRoot" ] || \
                                 [ "${dir}" == "/TFTPBoot" ]; then
                              dir=
                          fi
                          destbase=$(echo ${i}|awk -F':' '{print $4}')
                          echo ${destbase}${dir}|sed -e 's|/$||'
                      done)
    UNMOUNT_TARGETS=$(for i in ${MOUNTED_TARGETS}; do
                          echo ${i}
                      done | sort -r)
    return 0
}

check_targets_mounted() {
    echo "${CMDNAME}: Checking if target filesystems are mounted."
    all_mounted=1
    for i in ${MOUNTED_TARGETS}; do
        mounted=$(mount|awk -v var=${i} '$3==var{print 1}')
        all_mounted=$((all_mounted & mounted))
    done
    if [ ${all_mounted} -eq 0 ]; then
        echo "${CMDNAME}: (One of) target filesystems are not mounted."
        exit 1
    fi
    return 0
}

main() {
    while getopts ?h:muc OPT; do
        case ${OPT} in
            "?")
                print_usage ;;
            "h")
                DESTHOST=${OPTARG} ;;
            "m")
                MOUNT=1 ;;
            "u")
                UNMOUNT=1 ;;
            "c")
                CHECK=1 ;;
        esac
    done
    if [ -z "${DESTHOST}" ]; then
        echo "${CMDNAME}: You must specify a target hostname with -h."
        exit 1
    fi
    . ${CONFDIR}/${DESTHOST}.conf
    setup_target_vars
    if [ ${MOUNT} -eq 1 ]; then
        mount_targets
    elif [ ${UNMOUNT} -eq 1 ]; then
        unmount_targets
    elif [ ${CHECK} -eq 1 ]; then
        check_targets_mounted
    fi
    return 0
}

main "${@}"
