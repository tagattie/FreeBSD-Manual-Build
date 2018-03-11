#! /bin/sh

ARCH=mips
BRANCH=releng111

# source common variables and functions
# shellcheck source=../common.sh
. "${CONFDIR}/common.sh"
# shellcheck source=../arch/amd64.sh
. "${CONFDIR}/arch/${ARCH}.sh"
# shellcheck source=../branch/releng111.sh
. "${CONFDIR}/branch/${BRANCH}.sh"

export DESTHOST=deervalley
CAPDDESTHOST=$(echo ${DESTHOST} | \
    awk '{print toupper(substr($0,1,1)) substr($0,2,length($0)-1)}')
export CAPDDESTHOST
KERNCONF=$(echo ${DESTHOST}|tr '[:lower:]' '[:upper:]')
export KERNCONF

export ROOTDIR_BASEDIR=/mnt/nfsroot
export ROOTDIR_MOUNTTYPE=nfs
export DESTROOTDIR=${ROOTDIR_BASEDIR}/${CAPDDESTHOST}
export TFTPDIR_BASEDIR=/mnt/tftpboot
export TFTPDIR_MOUNTTYPE=nfs
export DESTTFTPDIR=${TFTPDIR_BASEDIR}/${CAPDDESTHOST}

export ROOTDIR_DEST=${DESTROOTDIR}${ROOTDIR}
export BOOTDIR_DEST=${DESTROOTDIR}${BOOTDIR}

export MOUNT_TARGETS="\
    nas:/NFSRoot:${ROOTDIR_MOUNTTYPE}:${ROOTDIR_BASEDIR} \
    nas:/TFTPBoot:${TFTPDIR_MOUNTTYPE}:${TFTPDIR_BASEDIR}"

do_post_install_kernel() {
    if [ "${MAKE_TARGET}" = "installkernel" ]; then
        UBOOTKERNLOADADDR="0x80050000"
        UBOOTKERNENTRYPOINT="0x80050100"
        UBOOTKERNIMGFILE="kernel.lzma.uImage"
        echo "${CMDNAME}: Making kernel image for network boot."
        /usr/local/bin/lzma e ${BOOTDIR_DEST}/kernel/kernel \
                            ${BOOTDIR_DEST}/kernel/kernel.lzma
        UBOOTKERNENTRYPOINT=$(elfdump -e ${BOOTDIR_DEST}/kernel/kernel | \
                                  grep e_entry | \
                                  awk -F':' '{print $2}')
        mkimage -A mips \
                -O linux \
                -T kernel \
                -C lzma \
                -a ${UBOOTKERNLOADADDR} \
                -e ${UBOOTKERNENTRYPOINT} \
                -n FreeBSD \
                -d ${BOOTDIR_DEST}/kernel/kernel.lzma \
                ${BOOTDIR_DEST}/kernel/${UBOOTKERNIMGFILE}
        echo "${CMDNAME}: Copying kernel image to TFTP boot directory."
        (mkdir -p ${DESTTFTPDIR} &&
             cd ${DESTTFTPDIR} &&
             mv -f ${UBOOTKERNIMGFILE} ${UBOOTKERNIMGFILE}.old &&
             install -c ${BOOTDIR_DEST}/kernel/${UBOOTKERNIMGFILE} .)
    fi
    return 0
}

do_post_install_world() {
    return 0
}
