#! /bin/sh -xe

export LANG=C
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

CONFDIR=$(pwd)/conf
print_usage() {
    echo "Usage: ${CMDNAME} [-?|-h hostname [-n] [make_target ...]]"
    echo "Options:"
    echo "  -?: Show this message."
    echo "  -h: Target hostname."
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
    MAKE_JOBS_NUM=$NJOBS
    if [ "${1}" = "buildworld" ] || \
           [ "${1}" = "buildkernel" ]; then
        MAKE_FLAGS="-j ${MAKE_JOBS_NUM} ${MAKE_FLAGS}"
    fi

    if [ -n "${OBJDIR}" ]; then
        MAKE_ENVS="env MAKEOBJDIRPREFIX=${OBJDIR}"
    fi

    MAKE_ARGS="DESTDIR=${DESTDIR}"
    if [ -n "${KENCONF}" ]; then
        MAKE_ARGS="KERNCONF=${KERNCONF}"
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


print_exec_command() {
    MAKE_COMMAND="${TIME} ${MAKE} ${MAKE_FLAGS} ${MAKE_ENV} ${MAKE_TARGET}"
    echo "=== Custom build settings ===================================="
    echo "COMMAND: ${COMMAND}"
    echo "SRCDIR: ${SRCDIR}"
    echo "KERNCONF: ${KERNCONF}"
    echo "TARGET: ${UNAME_m}"
    echo "TARGET_ARCH: ${UNAME_p}"
    echo "DESTDIR: ${DESTDIR}"
    echo "MAKE_FLAGS: ${MAKE_FLAGS}"
    echo "MAKE_ENV: ${MAKE_ENV}"
    echo "MAKE_TARGET: ${MAKE_TARGET}"
    echo "MAKE_COMMAND: ${MAKE_COMMAND}"
    echo "=============================================================="
    return 0
} # print_make_command()

print_finish_message() {
    echo "Making ${MAKE_TARGET} started at ${STARTDATE}."
    echo "Making ${MAKE_TARGET} finished at ${FINISHDATE}."
    return 0
} # print_finish_message()

main() {
    STARTDATE=$(date)
    if [ $# -eq 0 ]; then
        print_usage
    else
        while getopts ?h:n OPT; do
            case ${OPT} in
                "?")
                    print_usage ;;
                "h")
                    DESTHOST=${OPTARG} ;;
                "n")
                    MAKE_FLAGS="-n ${MAKE_FLAGS}" ;;
            esac
        done
    fi
    . ${CONFDIR}/${DESTHOST}.conf
    shift $((${OPTIND} - 1))
    fi
    return ${ESTATUS}
    for i in ${MAKE_TARGETS}; do
        STARTDATE=$(date)

        setup_make_command "${i}"
        if [ "${i}" = "installworld" ] || \
               [ "${i}" = "installkernel" ] || \
               [ "${i}" = "distribution" ]; then
            $(pwd)/Mount.sh -h "${DESTHOST}" -c
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
} # main()

main "${@}"
