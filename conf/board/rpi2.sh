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
    DTB_FILES="dtb/rpi2.dtb"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}"
    for i in ${DTB_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${BOOTDIR_DEST}/${i}" \
                "${BOOTFATDIR_DEST}"
    done
    return 0
}

do_post_installworld() {
    echo "${CMDNAME}: Copying loader files to FAT partition."
    UBLDR_FILES="ubldr ubldr.bin"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}"
    for i in ${UBLDR_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${BOOTDIR_DEST}/${i}" \
                "${BOOTFATDIR_DEST}"
    done
    return 0
} # do_post_installworld()

install_boot() {
    echo "${CMDNAME}: Copying RPI firmware files to FAT partition."
    RPI_MASTERDIR=${LOCALBASE}/share/rpi-firmware
    RPI_FILES="bootcode.bin config.txt \
        fixup.dat fixup_cd.dat fixup_db.dat fixup_x.dat \
        start.elf start_cd.elf start_db.elf start_x.elf"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}"
    for i in ${RPI_FILES}; do
        ${SUDO} ${INSTALL_FILE} "${RPI_MASTERDIR}/${i}" "${BOOTFATDIR_DEST}"
    done

    echo "${CMDNAME}: Copying boot files to FAT partition."
    UBOOT_MASTERDIR=${LOCALBASE}/share/u-boot/u-boot-rpi2
    UBOOT_FILES="u-boot.bin"
    for i in ${UBOOT_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${UBOOT_MASTERDIR}/${i}" \
                "${BOOTFATDIR_DEST}"
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
