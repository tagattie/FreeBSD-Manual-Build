#! /bin/sh

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/mips.sh
. "${CONFDIR}/arch/mips.sh"
# shellcheck source=../branch/current.sh
. "${CONFDIR}/branch/current.sh"

export DESTHOST=mips-current
export CAPDDESTHOST=Mips-Current
export KERNCONF=CARAMBOLA2

export MAKE_FLAGS_ADD="-DCROSS_TOOLCHAIN=mips-gcc"

export OBJDIR=/var/tmp/jenkins/freebsd/obj/current

export DESTROOT_BASEDIR=/var
export DESTROOT_MOUNTTYPE=zfs
export DESTDIR=${DESTROOT_BASEDIR}/tmp/jenkins/freebsd/destdir/${DESTHOST}

export DESTROOTDIR=${DESTDIR}${ROOTDIR}

export MOUNT_TARGETS="localhost:${ROOTDIR}:${DESTROOT_MOUNTTYPE}:${DESTROOT_BASEDIR}"
