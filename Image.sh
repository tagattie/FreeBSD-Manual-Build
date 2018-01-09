#! /bin/sh -xe

export  LANG=C
export  PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin

BASEDIR=$(cd "$(dirname "$0")" && pwd)
CONFDIR=${BASEDIR}/conf
WORKDIR=${BASEDIR}/work

CMDNAME=$(basename "$0")

print_usage() {
    echo "Usage: ${CMDNAME} [-?|-h hostname [-c file]]"
    echo "Options:"
    echo "  -?: Show this message."
    echo "  -c: Extra configuration file (for overriding defaults)."
    echo "  -h: Target hostname."
    exit 0
} # print_usage()

# Create a file and configure it as a memory disk
create_image_file() {
    IMAGE_FILE=FreeBSD-${DESTHOST}-${BUILDNAME}.img

    truncate -s "${IMG_SIZE}" "${WORKDIR}/${IMAGE_FILE}"
    MD_DEVNAME=$(${SUDO} \
                     mdconfig \
                     -a \
                     -t vnode \
                     -x "${SECTORS_PER_TRACK}" \
                     -y "${HEADS_PER_CYLINDER}" \
                     -f "${WORKDIR}/${IMAGE_FILE}")
    if [ -z "${MD_DEVNAME}" ]; then
        echo "${CMDNAME}: Could not allocate memory disk device."
        exit 1
    fi
    echo "${CMDNAME}: Memory disk device name is ${MD_DEVNAME}."

    return 0
} # create_disk_image()

# Create partition scheme
create_partition_scheme() {
    ${SUDO} gpart create -s "${PART_SCHEME}" "${MD_DEVNAME}"
    return 0
} # create_partition_scheme()

create_and_mount_boot_partition() {
    # Create FAT32(LBA-addressable) partition for boot (1st slice)
    ${SUDO} \
        gpart add \
        -a "${SECTORS_PER_TRACK}" \
        -b "${START_SECTOR}" \
        -s $((BOOT_PART_SIZE/BYTES_PER_SECTOR-BOOT_PART_SECTOR_MARGIN)) \
        -t "${BOOT_PART_TYPE}" \
        "${MD_DEVNAME}"
    # Make the slice (boot slice) active (bootable)
    ${SUDO} gpart set -a active -i 1 "${MD_DEVNAME}"
    # Create FAT16 filesystem in the boot slice
    ${SUDO} \
        newfs_msdos \
        -L "${BOOT_PART_LABEL}" \
        -F "${BOOT_PART_FS}" \
        "/dev/${MD_DEVNAME}s1"
    # Mount the FAT16 filesystem and copy necessary files onto it
    ${SUDO} mkdir -p "${WORKDIR}/${BOOT_PART_LABEL}"
    ${SUDO} \
        mount \
        -t "${BOOT_PART_FSTYPE}" \
        -l "/dev/${MD_DEVNAME}s1" \
        "${WORKDIR}/${BOOT_PART_LABEL}"
    return 0
} # create_and_mount_boot_partition()

unmount_boot_partition() {
    ${SUDO} umount "${WORKDIR}/${BOOT_PART_LABEL}"
    ${SUDO} rmdir "${WORKDIR}/${BOOT_PART_LABEL}"
    return 0
} # unmount_boot_partition()

create_and_mount_bsd_partition() {
    # Create FreeBSD partition (2nd slice)
    ${SUDO} gpart add -t "${BSD_PART_TYPE}" "${MD_DEVNAME}"
    # Set partition scheme of the FreeBSD slice
    ${SUDO} gpart create -s "${BSD_PART_SCHEME}" "${MD_DEVNAME}s2"
    # Add freebsd-ufs partition (make alignment to 64KiB)
    ${SUDO} \
        gpart add \
        -a "${BSD_PART_FSALIGN}" \
        -t "${BSD_PART_FSTYPE}" \
        "${MD_DEVNAME}s2"
    # Create UFS filesystem in the FreeBSD slice
    ${SUDO} newfs -U -j -t -L "${BSD_PART_FSLABEL}" "/dev/${MD_DEVNAME}s2a"
    # Mount the UFS filesystem and copy distribution onto it
    ${SUDO} mkdir -p "${WORKDIR}/${BSD_PART_FSLABEL}"
    ${SUDO} mount -t ufs \
            "/dev/${MD_DEVNAME}s2a" \
            "${WORKDIR}/${BSD_PART_FSLABEL}"
    return 0
}

populate_root_partition() {
    ${SUDO} rsync \
            -aHv \
            --exclude="${BOOTFATDIR_DEST}" \
            --exclude="${BOOTEFIDIR_DEST}" \
            --stats \
            "${ROOTDIR_DEST}/" \
            "${WORKDIR}/${BSD_PART_FSLABEL}"
    return $?
} # populate_root_partition()

copy_overlay_files() {
    for i in ${OVERLAY_FILES}; do
        ${SUDO} ${INSTALL_FILE} \
                "${BASEDIR}/overlay/${BOARD_NAME}/${i}" \
                "${WORKDIR}/${BSD_PART_FSLABEL}/${i}"
    done
    ${SUDO} touch "${WORKDIR}/${BSD_PART_FSLABEL}/${FIRST_BOOT_SENTINEL}"
    return 0
} # copy_overlay_files()

unmount_bsd_partition() {
    ${SUDO} umount "${WORKDIR}/${BSD_PART_FSLABEL}"
    ${SUDO} rmdir "${WORKDIR}/${BSD_PART_FSLABEL}"
    return 0
} # unmount_bsd_partition()

close_image_file() {
    ${SUDO} mdconfig -d -u "${MD_DEVNAME}"
    return 0
}

copy_image_and_finish() {
    mkdir -p "${IMAGEDIR}"
    cp -pf "${WORKDIR}/${IMAGE_FILE}" "${IMAGEDIR}"

    echo "Your image is ready at ${IMAGEDIR}/${IMAGE_FILE}."
    echo "To write the image to an SD card, do the following command:"
    echo "sudo dd if=${IMAGEDIR}/${IMAGE_FILE} of=/dev/<your SD card> bs=1m"

    return 0
}

main() {
    if [ $# -eq 0 ]; then
        print_usage
    else
        while getopts \?c:h: OPT; do
            case ${OPT} in
                "?")
                    print_usage ;;
                "c")
                    EXTRA_CONF=${OPTARG} ;;
                "h")
                    DESTHOST=${OPTARG} ;;
            esac
        done
    fi

    . "${CONFDIR}/host/${DESTHOST}.sh"
    if [ -n "${EXTRA_CONF}" ]; then
        . "${EXTRA_CONF}"
    fi

    mkdir -p "${WORKDIR}"

    create_image_file
    create_partition_scheme
    setup_boot_partition
    setup_bsd_partition
    close_image_file
    copy_image_and_finish

    rm -rf "${WORKDIR}"

    return 0
} # main()

main "${@}"
