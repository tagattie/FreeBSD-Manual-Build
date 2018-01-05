#! /bin/sh -xe

export LANG=C
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

BASEDIR=$(cd "$(dirname "$0")" && pwd)
CONFDIR=${BASEDIR}/conf
export CONFDIR

print_usage() {
    echo "Usage: ${CMDNAME} [-?|-h hostname [-nj][-c file] make_target ...]"
    echo "Options:"
    echo "  -?: Show this message."
    echo "  -c: Extra configuration file (for overriding defaults)."
    echo "  -h: Target hostname."
    echo "  -j: Number of parallel jobs."
    echo "  -n: Dry run."
    exit 0
} # print_usage()

setup_make_command() {
    SUDO="sudo"
    TIME="time -l"
    MAKE="make"

    MAKE_FLAGS="-DDB_FROM_SRC -DNO_FSCHG"
    if [ -n "${MAKE_FLAGS_ADD}" ]; then
        MAKE_FLAGS="${MAKE_FLAGS} ${MAKE_FLAGS_ADD}"
    fi
    if [ -z "${MAKE_JOBS_NUM}" ]; then
        MAKE_JOBS_NUM=$NJOBS
    fi
    if [ "${1}" = "buildworld" ] || \
           [ "${1}" = "buildkernel" ]; then
        MAKE_FLAGS="-j ${MAKE_JOBS_NUM} ${MAKE_FLAGS}"
    fi

    if [ -n "${OBJDIR}" ]; then
        MAKE_ENVS="env MAKEOBJDIRPREFIX=${OBJDIR}"
    fi

    MAKE_ARGS="DESTDIR=${DESTDIR}"
    if [ -n "${KERNCONF}" ]; then
        MAKE_ARGS="${MAKE_ARGS} KERNCONF=${KERNCONF}"
    fi
    if [ -n "${UNAME_m}" ]; then
        MAKE_ARGS="${MAKE_ARGS} TARGET=${UNAME_m}"
    fi
    if [ -n "${UNAME_p}" ]; then
        MAKE_ARGS="${MAKE_ARGS} TARGET_ARCH=${UNAME_p}"
    fi
    if [ -n "${UBLDR_LOADADDR}" ]; then
        MAKE_ARGS="${MAKE_ARGS} UBLDR_LOADADDR=${UBLDR_LOADADDR}"
    fi

    return 0
} # setup_make_command()

print_make_command() {
    MAKE_COMMAND="${TIME} ${SUDO} ${MAKE_ENVS} \
        ${MAKE} ${MAKE_FLAGS} ${MAKE_ARGS} ${1}"
    echo "=== Custom build settings ===================================="
    echo "COMMAND: ${COMMAND}"
    echo "SRCDIR: ${SRCDIR}"
    echo "DESTDIR: ${DESTDIR}"
    echo "KERNCONF: ${KERNCONF}"
    echo "TARGET: ${UNAME_m}"
    echo "TARGET_ARCH: ${UNAME_p}"
    echo "MAKE_ENVS: ${MAKE_ENVS}"
    echo "MAKE_FLAGS: ${MAKE_FLAGS}"
    echo "MAKE_ARGS: ${MAKE_ARGS}"
    echo "MAKE_TARGETS: ${1}"
    echo "MAKE_COMMAND: ${MAKE_COMMAND}"
    echo "=============================================================="
    return 0
} # print_make_command()

print_finish_message() {
    echo "Making ${1} started at ${STARTDATE}."
    echo "Making ${1} finished at ${FINISHDATE}."
    return 0
} # print_finish_message()

main() {
    if [ $# -eq 0 ]; then
        print_usage
    else
        while getopts \?c:h:j:n OPT; do
            case ${OPT} in
                "?")
                    print_usage ;;
                "c")
                    EXTRA_CONF=${OPTARG} ;;
                "h")
                    DESTHOST=${OPTARG} ;;
                "j")
                    MAKE_JOBS_NUM=${OPTARG} ;;
                "n")
                    MAKE_FLAGS="-n ${MAKE_FLAGS}" ;;
            esac
        done
    fi

    COMMAND="$0 $*"
    CMDNAME=$(basename "$0")
    shift $((OPTIND - 1))
    MAKE_TARGETS=$*

    . "${CONFDIR}/host/${DESTHOST}.sh"
    if [ -n "${EXTRA_CONF}" ]; then
        . "${EXTRA_CONF}"
    fi

    if [ -z "${SRCDIR}" ] || \
           [ -z "${DESTDIR}" ]; then
        echo "${CMDNAME}: You must specify both src and dst directories."
        exit 1
    fi

    for i in ${MAKE_TARGETS}; do
        STARTDATE=$(date)

        setup_make_command "${i}"
        if [ "${i}" = "installworld" ] || \
               [ "${i}" = "installkernel" ] || \
               [ "${i}" = "distribution" ]; then
            "${BASEDIR}"/Mount.sh -h "${DESTHOST}" -c
        fi

        print_make_command "${i}"
        # continue
        (cd "${SRCDIR}" && ${MAKE_COMMAND})
        ESTATUS=$?
        if [ $ESTATUS -eq 0 ]; then
            if [ "${i}" = "installkernel" ]; then
                do_post_installkernel
            elif [ "${i}" = "installworld" ]; then
                do_post_installworld
            fi
        else
            exit $ESTATUS
        fi

        FINISHDATE=$(date)
        print_finish_message "${1}"
    done

    return 0
} # main()

main "${@}"
