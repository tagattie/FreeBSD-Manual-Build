#! /bin/sh

ARCH=mips
BRANCH=current

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/mips.sh
. "${CONFDIR}/arch/${ARCH}.sh"
# shellcheck source=../branch/current.sh
. "${CONFDIR}/branch/${BRANCH}.sh"

export DESTHOST=${ARCH}-${BRANCH}
CAPDDESTHOST=$(echo ${DESTHOST} | \
    awk '{print toupper(substr($0,1,1)) substr($0,2,length($0)-1)}')
export CAPDDESTHOST
export KERNCONF=CARAMBOLA2 # no GENERIC kernel config provided

export MAKE_FLAGS_ADD="-DCROSS_TOOLCHAIN=mips-gcc"

export OBJDIR_BASEDIR=/var/tmp/jenkins/freebsd/obj
export OBJDIR=${OBJDIR_BASEDIR}/${DESTHOST}

export DESTROOT_BASEDIR=/
export DESTROOT_MOUNTTYPE=zfs
export DESTDIR_BASEDIR=/var/tmp/jenkins/freebsd/destdir
export DESTDIR=${DESTROOT_BASEDIR}${DESTDIR_BASEDIR}/${DESTHOST}

export DESTROOTDIR=${DESTDIR}${ROOTDIR}

export MOUNT_TARGETS="localhost:${ROOTDIR}:${DESTROOT_MOUNTTYPE}:${DESTROOT_BASEDIR}"