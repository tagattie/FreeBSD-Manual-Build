#! /bin/sh

# source common variables for boards
# shellcheck source=./common.sh
. "${CONFDIR}/board/common.sh"

# Image size is 1GiB
export IMG_SIZE=$((1*GiB))
export IMG_SIZEMB=$((IMG_SIZE/MiB))
# Boot partition size is 16MiB
export BOOT_PART_SIZE=$((16*MiB))
export BOOT_PART_SIZEMB=$((BOOT_PART_SIZE/MiB))

do_post_installkernel() {
    echo "${CMDNAME}: Making necessary DTB file hard links."
    (cd "${BOOTDIR_DEST}/dtb" && \
         ${SUDO} ln -f beaglebone.dtb am335x-bone.dtb &&
         ${SUDO} ln -f beaglebone-black.dtb am335x-boneblack.dtb)
    return 0
}

do_post_installworld() {
    UBLDR_FILES="ubldr ubldr.bin"
    echo "${CMDNAME}: Copying loader files to FAT partition."
    for i in ${UBLDR_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${BOOTDIR_DEST}/${i}" \
                "${BOOTFATDIR_DEST}"
    done
    return 0
}

install_boot() {
    echo "${CMDNAME}: Copying boot files to FAT partition."
    UBOOT_MASTERDIR=${LOCALBASE}/share/u-boot/u-boot-beaglebone
    UBOOT_FILES="MLO u-boot.img"
    for i in ${UBOOT_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${UBOOT_MASTERDIR}/${i}" \
                "${BOOTFATDIR_DEST}"
    done
    return 0
}
