#! /bin/sh

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/mips64.sh
. "${CONFDIR}/arch/mips64.sh"
# shellcheck source=../branch/releng111.sh
. "${CONFDIR}/branch/releng111.sh"
# shellcheck source=../board/erl.sh
. "${CONFDIR}/board/erl.sh"

export DESTHOST=whitewater
CAPDDESTHOST=$(echo ${DESTHOST} | \
    awk '{print toupper(substr($0,1,1)) substr($0,2,length($0)-1)}')
export CAPDDESTHOST
KERNCONF=$(echo ${DESTHOST}|tr '[:lower:]' '[:upper:]')
export KERNCONF

#export MAKE_FLAGS_ADD="-DCROSS_TOOLCHAIN=mips64-gcc"

export DESTDIR_BASEDIR=/mnt
export DESTDIR_MOUNTTYPE=nfs
export DESTDIR=${DESTDIR_BASEDIR}/${DESTHOST}

export MOUNT_TARGETS="\
    ${DESTHOST}:${ROOTDIR}:${DESTDIR_MOUNTTYPE}:${DESTDIR} \
    ${DESTHOST}:${BOOTFATDIR}:${DESTDIR_MOUNTTYPE}:${DESTDIR}"

export ROOTDIR_DEST=${DESTDIR}${ROOTDIR}
export BOOTDIR_DEST=${DESTDIR}${BOOTDIR}
export BOOTFATDIR_DEST=${DESTDIR}${BOOTFATDIR}
