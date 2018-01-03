#! /bin/sh

export SRCDIR=/usr/src
export OBJDIR=/usr/obj

export DESTROOT_BASEDIR=/mnt
export DESTROOT_MOUNTTYPE=nfs
export DESTDIR=${DESTROOT_BASEDIR}/${DESTHOST}

export ROOTDIR=/
export BOOTDIR=/boot
export FATBOOTDIR=/boot/msdos

NJOBS=$(sysctl hw.ncpu|awk '{print $NF}')
export NJOBS

# these functions will be overridden by host-specific conf
post_installkernel() {
    return 0
}
post_installworld() {
	return 0
}
install_boot() {
    return 0
}
