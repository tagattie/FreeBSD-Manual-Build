#! /bin/sh

# source common variables for boards
# shellcheck source=./common.sh
. "${CONFDIR}/board/common.sh"

export BOARD_NAME=rpi2

# Image size is 2GiB
export IMG_SIZE=$((2*GiB))
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
    echo "${CMDNAME}: Copying u-boot loader files to FAT partition."
    UBLDR_FILES="ubldr.bin"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}"
    for i in ${UBLDR_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${BOOTDIR_DEST}/${i}" \
                "${BOOTFATDIR_DEST}"
    done

    echo "${CMDNAME}: Copying loader file to FAT partition."
    BOOT_FILE="loader_lua.efi"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}/EFI/BOOT"
    ${SUDO} ${INSTALL_FILE} \
            "${BOOTDIR_DEST}/${BOOT_FILE}" \
            "${BOOTFATDIR_DEST}/EFI/BOOT/bootarm.efi"

    return 0
} # do_post_installworld()

install_boot() {
    echo "${CMDNAME}: Copying u-boot files to FAT partition."
    UBOOT_MASTERDIR=${LOCALBASE}/share/u-boot/u-boot-rpi2
    UBOOT_FILES="u-boot.bin"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}"
    for i in ${UBOOT_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${UBOOT_MASTERDIR}/${i}" \
                "${BOOTFATDIR_DEST}"
    done

    echo "${CMDNAME}: Copying RPI firmware files to FAT partition."
    RPI_MASTERDIR=${LOCALBASE}/share/rpi-firmware
    RPI_FILES="bootcode.bin config.txt \
        fixup.dat fixup_cd.dat fixup_db.dat fixup_x.dat \
        start.elf start_cd.elf start_db.elf start_x.elf \
        bcm2709-rpi-2-b.dtb \
        overlays/mmc.dtbo"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}/overlays"
    for i in ${RPI_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${RPI_MASTERDIR}/${i}" \
                "${BOOTFATDIR_DEST}/${i}"
    done

    return 0
} # install_boot()

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
