#! /bin/sh -xe

export LANG=C
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

BASEDIR=$(cd "$(dirname "$0")" && pwd)
CONFDIR=${BASEDIR}/conf
export CONFDIR

print_usage() {
    echo "Usage: ${CMDNAME} [-?] branch"
    echo "Options:"
    echo "  -?: Show this message."
    exit 0
} # print_usage()

main() {
    CMDNAME=$(basename "$0")
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

    shift $((OPTIND - 1))
    BRANCH=$*

    . "${CONFDIR}/branch/${BRANCH}.sh"

    if [ -z "${SRCDIR}" ]; then
        echo "${CMDNAME}: You must specify branch."
        exit 1
    fi

    svnlite status -qu "${SRCDIR}" | wc -l

    return 0
} # main()

main "${@}"
