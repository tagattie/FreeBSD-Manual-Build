#! /bin/sh

ARCH=aarch64
BRANCH=current

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/aarch64.sh
. "${CONFDIR}/arch/${ARCH}.sh"
# shellcheck source=../branch/current.sh
. "${CONFDIR}/branch/${BRANCH}.sh"

export DESTHOST=${ARCH}-${BRANCH}
CAPDDESTHOST=$(echo ${DESTHOST} | \
    awk '{print toupper(substr($0,1,1)) substr($0,2,length($0)-1)}')
export CAPDDESTHOST
export KERNCONF=GENERIC

export OBJDIR_BASEDIR=/var/tmp/jenkins/freebsd/obj
export OBJDIR=${OBJDIR_BASEDIR}/${DESTHOST}

export DESTDIR_BASEDIR=/var/tmp/jenkins/freebsd/destdir
export DESTDIR_MOUNTTYPE=zfs
export DESTDIR=${DESTDIR_BASEDIR}/${DESTHOST}

# dummy mount targets to pass check
export MOUNT_TARGETS="localhost:${ROOTDIR}:${DESTDIR_MOUNTTYPE}:${ROOTDIR}"
