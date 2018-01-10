#! /bin/sh

# source common variables for boards
# shellcheck source=./common.sh
. "${CONFDIR}/board/common.sh"

export BOARD_NAME=erl

# Image size is 2GiB
export IMG_SIZE=$((3*GiB))
export IMG_SIZEMB=$((IMG_SIZE/MiB))
# Boot partition size is 256MiB
export BOOT_PART_SIZE=$((256*MiB))
export BOOT_PART_SIZEMB=$((BOOT_PART_SIZE/MiB))
# BSD partition config for ERL
BSD_PART_FSMINFREE=$(bc -e "${IMG_SIZE}/1024*0.5" -e quit | \
                         awk -F'.' '{print $1}')
export BSD_PART_FSMINFREE
export BSD_PART_FSMARGIN=$((64*MiB))
export BSD_PART_FSSIZE=$(((IMG_SIZEMB-BOOT_PART_SIZEMB)*MiB-BSD_PART_FSMARGIN))

do_post_installkernel() {
    echo "${CMDNAME}: Copying kernel files to FAT partition."
    ${SUDO} mkdir -p "${BOOTFATDIR_DEST}"
    cd "${BOOTFATDIR_DEST}" || exit 1
    ${SUDO} rm -rf kernel.old
    if [ -d kernel ]; then
        ${SUDO} mv -f kernel kernel.old
    fi
    cd "${BOOTDIR_DEST}" || exit 1
    ${SUDO} rsync -rlDv --stats kernel "${BOOTFATDIR_DEST}"
    return 0
}

populate_boot_partition() {
    ${SUDO} rsync \
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

create_bsd_filesystem_image() {
    # Make UFS filesystem (big endian) from the distribution
    ${SUDO} \
        makefs \
        -B ${BSD_PART_FSENDIAN} \
        -f "${BSD_PART_FSMINFREE}" \
        -t ffs \
        -o label=${BSD_PART_FSLABEL} \
        -o version=2 \
        -s ${BSD_PART_FSSIZE} \
        "${WORKDIR}/$(basename "${IMAGE_FILE}" .img).ufs" \
        "${DESTDIR}"
    ${SUDO} \
        dd \
        if="${WORKDIR}/$(basename "${IMAGE_FILE}" .img).ufs" \
        of="/dev/${MD_DEVNAME}s2a" \
        bs=1m
    return 0
}

setup_bsd_partition() {
    create_bsd_partition
    copy_overlay_files
    create_placeholder_for_boot_partition
    populate_root_partition
    create_bsd_filesystem_image
    return 0
}
