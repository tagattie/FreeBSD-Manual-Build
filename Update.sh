#! /bin/sh -xe

export LANG=C
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

BASEDIR=$(cd "$(dirname "$0")" && pwd)
CONFDIR=${BASEDIR}/conf

CMDNAME=$(basename "$0")

print_usage() {
    echo "Usage: ${CMDNAME} [-?] branch"
    echo "Options:"
    echo "  -?: Show this message."

    exit 0
} # print_usage()

main() {
    if [ $# -eq 0 ]; then
        print_usage
    else
        while getopts \? OPT; do
            case ${OPT} in
                "?")
                    print_usage ;;
            esac
        done
    fi

    shift $((OPTIND-1))
    BRANCH=$*

    # shellcheck source=./conf/common.sh
    . "${CONFDIR}/common.sh"
    . "${CONFDIR}/branch/${BRANCH}.sh"

    if [ -z "${SRCDIR}" ]; then
        echo "${CMDNAME}: Branch must be specified."
        exit 1
    fi

    ${SUDO} ${SVN} update "${SRCDIR}"
    return $?
} # main()

main "${@}"
