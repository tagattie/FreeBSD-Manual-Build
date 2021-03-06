#! /bin/sh

export MAKE=make
export SUDO=sudo
export SVN=svnlite

export INSTALL_FILE="install -c -m 444"
export INSTALL_EXEC="install -c -m 755"

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
export BOOTFATDIR=/boot/msdos
export BOOTEFIDIR=/boot/efi

NJOBS=$(sysctl hw.ncpu|awk '{print $NF}')
export NJOBS

# these functions will be overridden by board-specific conf
do_post_installkernel() {
    return 0
}
do_post_installworld() {
	return 0
}
install_boot() {
    return 0
}
setup_boot_partition() {
    return 0
}
setup_bsd_partition() {
    return 0
}
