#! /bin/sh

# source common variables for boards
# shellcheck source=./common.sh
. "${CONFDIR}/board/common.sh"

export BOARD_NAME=rpi3

# Image size is 3GiB
export IMG_SIZE=$((3*GiB))
export IMG_SIZEMB=$((IMG_SIZE/MiB))
# Boot partition size is 32MiB
export BOOT_PART_SIZE=$((32*MiB))
export BOOT_PART_SIZEMB=$((BOOT_PART_SIZE/MiB))

do_post_installworld() {
    BOOT_FILES="boot1.efi"
    echo "${CMDNAME}: Copying boot files to EFI partition."
    ${SUDO} mkdir -p "${BOOTEFIDIR_DEST}/EFI/BOOT"
    ${SUDO} ${INSTALL_FILE} "${BOOTDIR_DEST}/${BOOT_FILES}" "${BOOTEFIDIR_DEST}/EFI/BOOT/bootaa64.efi"
    return 0
}

install_boot() {
    echo "${CMDNAME}: Copying boot files to EFI partition."
    UBOOT_MASTERDIR=${LOCALBASE}/share/u-boot/u-boot-rpi3
    UBOOT_FILES="u-boot.bin"
    ${SUDO} mkdir -p "${BOOTEFIDIR_DEST}"
    for i in ${UBOOT_FILES}; do
        ${SUDO} ${INSTALL_FILE} "${UBOOT_MASTERDIR}/${i}" "${BOOTEFIDIR_DEST}"
    done

    DTB_MASTERDIR=${LOCALBASE}/share/rpi-firmware
    DTB_FILES="armstub8.bin bootcode.bin config.txt \
        fixup_cd.dat fixup_db.dat fixup_x.dat \
        start_cd.elf start_db.elf start_x.elf start.elf \
        bcm2710-rpi-3-b.dtb \
        overlays/mmc.dtbo overlays/pi3-disable-bt.dtbo"
    ${SUDO} mkdir -p "${BOOTEFIDIR_DEST}/overlays"
    for i in ${DTB_FILES}; do
        ${SUDO} ${INSTALL_FILE} "${DTB_MASTERDIR}/${i}" "${BOOTEFIDIR_DEST}/${i}"
    done

    return 0
}

populate_boot_partition() {
    ${SUDO} rsync \
            -rlDv \
            --stats \
            "${BOOTEFIDIR_DEST}/" \
            "${WORKDIR}/${BOOT_PART_LABEL}"
    return $?
} # populate_boot_partition()

create_placeholder_for_boot_partition() {
    ${SUDO} mkdir -p "${WORKDIR}/${BSD_PART_FSLABEL}/${BOOTEFIDIR}"
    return 0
}
