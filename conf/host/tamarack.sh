#! /bin/sh

ARCH=aarch64
BRANCH=releng120
BOARD=rpi3

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/aarch64.sh
. "${CONFDIR}/arch/${ARCH}.sh"
# shellcheck source=../branch/releng120.sh
. "${CONFDIR}/branch/${BRANCH}.sh"
# shellcheck source=../board/rpi3.sh
. "${CONFDIR}/board/${BOARD}.sh"

export DESTHOST=tamarack
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
    ${DESTHOST}:${BOOTEFIDIR}:${DESTDIR_MOUNTTYPE}:${DESTDIR}"

export ROOTDIR_DEST=${DESTDIR}${ROOTDIR}
export BOOTDIR_DEST=${DESTDIR}${BOOTDIR}
export BOOTEFIDIR_DEST=${DESTDIR}${BOOTEFIDIR}
