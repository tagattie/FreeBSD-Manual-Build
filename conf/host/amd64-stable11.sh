#! /bin/sh

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/amd64.sh
. "${CONFDIR}/arch/amd64.sh"
# shellcheck source=../branch/stable11.sh
. "${CONFDIR}/branch/stable11.sh"

export DESTHOST=amd64-stable11
export CAPDDESTHOST=Amd64-Stable11
export KERNCONF=GENERIC

export OBJDIR=/var/tmp/jenkins/freebsd/obj/current

export DESTROOT_BASEDIR=/var
export DESTROOT_MOUNTTYPE=zfs
export DESTDIR=${DESTROOT_BASEDIR}/tmp/jenkins/freebsd/destdir/${DESTHOST}

export DESTROOTDIR=${DESTDIR}${ROOTDIR}

export MOUNT_TARGETS="localhost:${ROOTDIR}:${DESTROOT_MOUNTTYPE}:${DESTROOT_BASEDIR}"
