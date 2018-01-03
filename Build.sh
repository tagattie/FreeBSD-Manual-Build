#! /bin/sh -xe

export LANG=C
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
export NO_WERROR=1

LOCALBASE=/usr/local
CONFDIR=$(pwd)/conf

setup_make_env_preconf() {
    COMMAND="$0 $*"
    CMDNAME=$(basename $0)

    TIME="time -l"
    MAKE=make
    MAKE_FLAGS="-DDB_FROM_SRC -DNO_FSCHG"
    MAKE_JOBS_NUM=32

    return 0
} # setup_make_env_preconf()

print_usage() {
    echo "Usage: ${CMDNAME} -?|-h hostname [-n] make_target"
    echo "Options:"
    echo "  -?: Show this message."
    echo "  -h: Target hostname."
    echo "  -n: Dry run."
    exit 0
} # print_usage()

check_cmd_options() {
    if [ -z "${DESTHOST}" ]; then
        echo "${CMDNAME}: You must specify a target hostname with -h."
        exit 1
    fi
    return 0
} # check_cmd_options()

setup_make_env_postconf() {
    if [ -z "${SRCDIR}" ] || \
           [ -z "${DESTDIR}" ]; then
        echo "${CMDNAME}: You must specify both src and dst directories."
        exit 1
    fi

    MAKE_ENV="KERNCONF=${KERNCONF} TARGET=${UNAME_m} TARGET_ARCH=${UNAME_p} DESTDIR=${DESTDIR}"
    if [ -n "${UBLDR_LOADADDR}" ]; then
        MAKE_ENV="${MAKE_ENV} UBLDR_LOADADDR=${UBLDR_LOADADDR}"
    fi

    return 0
} # setup_make_env_postconf()

setup_make_flags() {
    if [ "${MAKE_TARGET}" == "buildworld" ] || \
           [ "${MAKE_TARGET}" == "buildkernel" ]; then
        MAKE_FLAGS="-j ${MAKE_JOBS_NUM} ${MAKE_FLAGS}"
    fi
    return 0
} # setup_make_flags()

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
    setup_make_env_preconf
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
    check_cmd_options
    . ${CONFDIR}/${DESTHOST}.conf
    setup_make_env_postconf
    shift $((${OPTIND} - 1))
    MAKE_TARGET=$@
    setup_make_flags
    if [ "${MAKE_TARGET}" == "installworld" ] || \
           [ "${MAKE_TARGET}" == "installkernel" ] || \
           [ "${MAKE_TARGET}" == "distribution" ]; then
        $(pwd)/Mount.sh -h ${DESTHOST} -c
    fi
    print_exec_command
#    exit 0
    (cd ${SRCDIR} && ${MAKE_COMMAND})
    ESTATUS=$?
    if [ $ESTATUS -eq 0 ]; then
        do_post_install_kernel
        do_post_install_world
    fi
    FINISHDATE=$(date)
    print_finish_message
    return ${ESTATUS}
} # main()

main "${@}"
