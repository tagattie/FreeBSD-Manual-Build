#! /bin/sh

DESTHOST=deervalley
CAPDDESTHOST=Deervalley
KERNCONF=DEERVALLEY

UNAME_m=mips
UNAME_p=mips

SRCDIR=/usr/src

ROOT_BASEDIR=/mnt/nfsroot
ROOT_MOUNTTYPE=nfs
TFTP_BASEDIR=/mnt/tftpboot
TFTP_MOUNTTYPE=nfs

DESTDIR=${ROOT_BASEDIR}/${CAPDDESTHOST}
TFTPDIR=${TFTP_BASEDIR}/${CAPDDESTHOST}

ROOTDIR=/
BOOTDIR=/boot

DESTROOTDIR=${DESTDIR}${ROOTDIR}
DESTBOOTDIR=${DESTDIR}${BOOTDIR}

MOUNT_TARGETS="nas:/NFSRoot:${ROOT_MOUNTTYPE}:${ROOT_BASEDIR} \
    nas:/TFTPBoot:${TFTP_MOUNTTYPE}:${TFTP_BASEDIR}"

do_post_install_kernel() {
    if [ "${MAKE_TARGET}" == "installkernel" ]; then
        UBOOTKERNLOADADDR="0x80050000"
        UBOOTKERNENTRYPOINT="0x80050100"
        UBOOTKERNIMGFILE="kernel.lzma.uImage"
        echo "${CMDNAME}: Making kernel image for network boot."
        /usr/local/bin/lzma e ${DESTBOOTDIR}/kernel/kernel \
                            ${DESTBOOTDIR}/kernel/kernel.lzma
        UBOOTKERNENTRYPOINT=$(elfdump -e ${DESTBOOTDIR}/kernel/kernel | \
                                  grep e_entry | \
                                  awk -F':' '{print $2}')
        mkimage -A mips \
                -O linux \
                -T kernel \
                -C lzma \
                -a 0x80050000 \
                -e ${UBOOTKERNENTRYPOINT} \
                -n FreeBSD \
                -d ${DESTBOOTDIR}/kernel/kernel.lzma \
                ${DESTBOOTDIR}/kernel/${UBOOTKERNIMGFILE}
        echo "${CMDNAME}: Copying kernel image to TFTP boot directory."
        (mkdir -p ${TFTPDIR} &&
             cd ${TFTPDIR} &&
             mv -f ${UBOOTKERNIMGFILE} ${UBOOTKERNIMGFILE}.old &&
             install -c ${DESTBOOTDIR}/kernel/${UBOOTKERNIMGFILE} .)
    fi
    return 0
}

do_post_install_world() {
    return 0
}
