#! /bin/sh -xe

export LANG=C
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

BASEDIR=$(cd "$(dirname "$0")" && pwd)
CONFDIR=${BASEDIR}/conf

CMDNAME=$(basename "$0")

print_usage() {
    echo "Usage: ${CMDNAME} [-?|-h hostname [-c file]]"
    echo "Options:"
    echo "  -?: Show this message."
    echo "  -c: Extra configuration file (for overriding defaults)."
    echo "  -h: Target hostname."
    exit 0
} # print_usage()

main() {
    if [ $# -eq 0 ]; then
        print_usage
    else
        while getopts \?h:c: OPT; do
            case ${OPT} in
                "?")
                    print_usage ;;
                "c")
                    EXTRA_CONF=${OPTARG} ;;
                "h")
                    DESTHOST=${OPTARG} ;;
            esac
        done
    fi

    if [ -z "${DESTHOST}" ]; then
        echo "${CMDNAME}: You must specify a target hostname with -h."
        exit 1
    fi

    . "${CONFDIR}/host/${DESTHOST}.sh"
    if [ -n "${EXTRA_CONF}" ]; then
        . "${EXTRA_CONF}"
    fi

    install_boot

    return 0
} # main()

main "${@}"
