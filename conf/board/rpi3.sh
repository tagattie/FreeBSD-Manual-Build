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

do_post_installkernel() {
    echo "${CMDNAME}: Copying DTB files to FAT partition."
    DTB_DIR="dtb"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}/${DTB_DIR}"
    ${SUDO} rsync -rlDv --stats \
            "${BOOTDIR_DEST}/${DTB_DIR}/" \
            "${BOOTFATDIR_DEST}/${DTB_DIR}"

    return 0
}

do_post_installworld() {
    echo "${CMDNAME}: Copying loader file to EFI partition."
    BOOT_FILE="loader_lua.efi"
    ${SUDO} mkdir -p "${BOOTEFIDIR_DEST}/EFI/BOOT"
    ${SUDO} ${INSTALL_FILE} \
            "${BOOTDIR_DEST}/${BOOT_FILE}" \
            "${BOOTEFIDIR_DEST}/EFI/BOOT/bootaa64.efi"

    return 0
}

install_boot() {
    echo "${CMDNAME}: Copying u-boot files to EFI partition."
    UBOOT_MASTERDIR=${LOCALBASE}/share/u-boot/u-boot-rpi3
    UBOOT_FILES="u-boot.bin"
    ${SUDO} mkdir -p "${BOOTEFIDIR_DEST}"
    for i in ${UBOOT_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${UBOOT_MASTERDIR}/${i}" \
                "${BOOTEFIDIR_DEST}"
    done

    echo "${CMDNAME}: Copying RPI firmware files to FAT partition."
    RPI_MASTERDIR=${LOCALBASE}/share/rpi-firmware
    RPI_FILES="armstub8.bin bootcode.bin \
        fixup_cd.dat fixup_db.dat fixup_x.dat fixup.dat \
        start_cd.elf start_db.elf start_x.elf start.elf \
        bcm2710-rpi-3-b.dtb \
        overlays/mmc.dtbo overlays/pwm.dtbo overlays/pi3-disable-bt.dtbo"
    ${SUDO} mkdir -p "${BOOTEFIDIR_DEST}/overlays"
    for i in ${RPI_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${RPI_MASTERDIR}/${i}" \
                "${BOOTEFIDIR_DEST}/${i}"
    done
    ${SUDO} ${INSTALL_FILE} \
            "${RPI_MASTERDIR}/config_rpi3.txt" \
            "${BOOTEFIDIR_DEST}/config.txt"

    return 0
}

populate_boot_partition() {
    ${SUDO} \
        rsync -rlDv --stats \
        "${BOOTEFIDIR_DEST}/" \
        "${WORKDIR}/${BOOT_PART_LABEL}"
    return $?
} # populate_boot_partition()

create_placeholder_for_boot_partition() {
    ${SUDO} mkdir -p "${WORKDIR}/${BSD_PART_FSLABEL}/${BOOTEFIDIR}"

    return 0
}
