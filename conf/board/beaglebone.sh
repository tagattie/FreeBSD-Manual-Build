#! /bin/sh

# source common variables for boards
# shellcheck source=./common.sh
. "${CONFDIR}/board/common.sh"

export BOARD_NAME=beaglebone

# Image size is 1GiB
export IMG_SIZE=$((1*GiB))
export IMG_SIZEMB=$((IMG_SIZE/MiB))
# Boot partition size is 16MiB
export BOOT_PART_SIZE=$((16*MiB))
export BOOT_PART_SIZEMB=$((BOOT_PART_SIZE/MiB))

do_post_installkernel() {
    echo "${CMDNAME}: Copying DTB files to FAT partition."
    DTB_DIR="dtb"
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}/${DTB_DIR}"
    ${SUDO} rsync -rlDv --stats "${BOOTDIR_DEST}/${DTB_DIR}/" "${BOOTFATDIR_DEST}/${DTB_DIR}"

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
    ${SUDO} mkdir -p "${BOOTEFIDIR_DEST}/EFI/BOOT"
    ${SUDO} ${INSTALL_FILE} "${BOOTDIR_DEST}/${BOOT_FILE}" "${BOOTEFIDIR_DEST}/EFI/BOOT/bootarm.efi"

    return 0
}

install_boot() {
    echo "${CMDNAME}: Copying boot files to FAT partition."
    UBOOT_MASTERDIR=${LOCALBASE}/share/u-boot/u-boot-beaglebone
    UBOOT_FILES="MLO u-boot.img"
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
