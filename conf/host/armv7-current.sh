#! /bin/sh

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/armv7.sh
. "${CONFDIR}/arch/armv7.sh"
# shellcheck source=../branch/current.sh
. "${CONFDIR}/branch/current.sh"

export DESTHOST=armv7-current
export CAPDDESTHOST=Armv7-Current
export KERNCONF=GENERIC

export OBJDIR=/var/tmp/jenkins/freebsd/obj/current

export DESTROOT_BASEDIR=/var
export DESTROOT_MOUNTTYPE=zfs
export DESTDIR=${DESTROOT_BASEDIR}/tmp/jenkins/freebsd/destdir/${DESTHOST}

export DESTROOTDIR=${DESTDIR}${ROOTDIR}

export MOUNT_TARGETS="localhost:${ROOTDIR}:${DESTROOT_MOUNTTYPE}:${DESTROOT_BASEDIR}"
