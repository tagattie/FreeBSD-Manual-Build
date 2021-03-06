#! /bin/sh

ARCH=armv7
BRANCH=releng120
BOARD=rpi2

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/armv7.sh
. "${CONFDIR}/arch/${ARCH}.sh"
# shellcheck source=../branch/releng120.sh
. "${CONFDIR}/branch/${BRANCH}.sh"
# shellcheck source=../board/rpi2.sh
. "${CONFDIR}/board/${BOARD}.sh"

export DESTHOST=sugarbush
CAPDDESTHOST=$(echo ${DESTHOST} | \
    awk '{print toupper(substr($0,1,1)) substr($0,2,length($0)-1)}')
export CAPDDESTHOST
KERNCONF=$(echo ${DESTHOST}|tr '[:lower:]' '[:upper:]')
export KERNCONF

export DESTDIR_BASEDIR=/mnt
export DESTDIR_MOUNTTYPE=nfs
export DESTDIR=${DESTDIR_BASEDIR}/${DESTHOST}

export MOUNT_TARGETS="\
    ${DESTHOST}:${ROOTDIR}:${DESTDIR_MOUNTTYPE}:${DESTDIR} \
    ${DESTHOST}:${BOOTFATDIR}:${DESTDIR_MOUNTTYPE}:${DESTDIR}"

export ROOTDIR_DEST=${DESTDIR}${ROOTDIR}
export BOOTDIR_DEST=${DESTDIR}${BOOTDIR}
export BOOTFATDIR_DEST=${DESTDIR}${BOOTFATDIR}
