#! /bin/sh

# source common variables for boards
# shellcheck source=./common.sh
. "${CONFDIR}/board/common.sh"

export BOARD_NAME=beaglebone

export UBLDR_LOADADDR=0x88000000

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
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}"
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
    UBOOT_FILES="MLO boot.scr u-boot.img"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}"
    for i in ${UBOOT_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${UBOOT_MASTERDIR}/${i}" \
                "${BOOTFATDIR_DEST}"
    done
    return 0
}

populate_boot_partition() {
    ${SUDO} \
        rsync \
        -rlDv \
        --stats \
        "${BOOTFATDIR_DEST}/" \
        "${WORKDIR}/${BOOT_PART_LABEL}"
    return $?
} # populate_boot_partition()

create_placeholder_for_boot_partition() {
    ${SUDO} mkdir -p "${WORKDIR}/${BSD_PART_FSLABEL}/${BOOTFATDIR}"
    return 0
}
