#! /bin/sh

ARCH=amd64
BRANCH=releng142

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/amd64.sh
. "${CONFDIR}/arch/${ARCH}.sh"
# shellcheck source=../branch/releng142.sh
. "${CONFDIR}/branch/${BRANCH}.sh"

export DESTHOST=taos
CAPDDESTHOST=$(echo ${DESTHOST} | \
    awk '{print toupper(substr($0,1,1)) substr($0,2,length($0)-1)}')
export CAPDDESTHOST
KERNCONF=$(echo ${DESTHOST}|tr '[:lower:]' '[:upper:]')
export KERNCONF

export DESTDIR_BASEDIR=/mnt
export DESTDIR_MOUNTTYPE=nfs
export DESTDIR=${DESTDIR_BASEDIR}/${DESTHOST}

MOUNT_TARGET_DIRS="/ /usr /var"
MOUNT_TARGETS=$(for i in ${MOUNT_TARGET_DIRS}; do
                    echo "${DESTHOST}:${i}:${DESTDIR_MOUNTTYPE}:${DESTDIR}"
                done)
export MOUNT_TARGETS
