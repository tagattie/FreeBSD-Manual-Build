#! /bin/sh -xe

export LANG=C
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

LOCALBASE=/usr/local
CONFDIR=$(pwd)/conf

CMDNAME=$(basename $0)

print_usage() {
    echo "Usage: ${CMDNAME} -?|-h hostname"
    echo "Options:"
    echo "  -?: Show this message."
    echo "  -h: Target hostname."
    exit 0
}

main() {
    while getopts ?h: OPT; do
        case ${OPT} in
            "?")
                print_usage ;;
            "h")
                DESTHOST=${OPTARG} ;;
        esac
    done
    if [ -z "${DESTHOST}" ]; then
        echo "${CMDNAME}: You must specify a target hostname with -h."
        exit 1
    fi
    . ${CONFDIR}/${DESTHOST}.conf
    install_boot
    return 0
}

main "${@}"
