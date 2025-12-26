#! /bin/sh

ARCH=amd64
BRANCH=releng150

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/amd64.sh
. "${CONFDIR}/arch/${ARCH}.sh"
# shellcheck source=../branch/releng150.sh
. "${CONFDIR}/branch/${BRANCH}.sh"

export DESTHOST=parkcity
CAPDDESTHOST=$(echo ${DESTHOST} | \
    awk '{print toupper(substr($0,1,1)) substr($0,2,length($0)-1)}')
export CAPDDESTHOST
KERNCONF=$(echo ${DESTHOST}|tr '[:lower:]' '[:upper:]')
export KERNCONF

export DESTDIR_BASEDIR=/
export DESTDIR_MOUNTTYPE=ufs
export DESTDIR=${DESTDIR_BASEDIR}

# dummy mount targets to pass check
export MOUNT_TARGETS="${DESTHOST}:${ROOTDIR}:${DESTDIR_MOUNTTYPE}:${DESTDIR}"
