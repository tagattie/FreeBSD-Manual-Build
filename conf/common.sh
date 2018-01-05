#! /bin/sh

BUILDNAME=$(date "+%Y-%m-%d-%H%M%S")
export BUILDNAME

export LOCALBASE=/usr/local

export SRCDIR=/usr/src
export OBJDIR=/usr/obj

export DESTDIR_BASEDIR=/
export DESTDIR_MOUNTTYPE=zfs
export DESTDIR=${DESTDIR_BASEDIR}

export ROOTDIR=/
export BOOTDIR=/boot
export FATBOOTDIR=/boot/msdos
export EFIBOOTDIR=/boot/efi

NJOBS=$(sysctl hw.ncpu|awk '{print $NF}')
export NJOBS

# these functions will be overridden by host-specific conf
do_post_installkernel() {
    return 0
}
do_post_installworld() {
	return 0
}
install_boot() {
    return 0
}
