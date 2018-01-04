#! /bin/sh

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/armv6.sh
. "${CONFDIR}/arch/armv6.sh"
# shellcheck source=../branch/releng111.sh
. "${CONFDIR}/branch/releng111.sh"

export DESTHOST=armv6-releng111
export CAPDDESTHOST=Armv6-Releng111
export KERNCONF=GENERIC

export OBJDIR=/var/tmp/jenkins/freebsd/obj/releng111

export DESTROOT_BASEDIR=/var
export DESTROOT_MOUNTTYPE=zfs
export DESTDIR=${DESTROOT_BASEDIR}/tmp/jenkins/freebsd/destdir/${DESTHOST}

export DESTROOTDIR=${DESTDIR}${ROOTDIR}

export MOUNT_TARGETS="localhost:${ROOTDIR}:${DESTROOT_MOUNTTYPE}:${DESTROOT_BASEDIR}"
