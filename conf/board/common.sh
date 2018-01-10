#! /bin/sh

# Basic units
export KiB=1024
export MiB=$((KiB*1024))
export GiB=$((MiB*1024))

# Traditional logical disk structure
export SECTORS_PER_TRACK=63
export HEADS_PER_CYLINDER=255
export BYTES_PER_SECTOR=512
export START_SECTOR=63

# Defaults for disk image file (possibly be overridden)
export IMG_SIZE=$((1*GiB))
export IMG_SIZEMB=$((IMG_SIZE/MiB))

# Default parition scheme is MBR
export PART_SCHEME=MBR

# Defaults for boot partition (possibly be overridden)
export BOOT_PART_SIZE=$((16*MiB))
export BOOT_PART_SIZEMB=$((BOOT_PART_SIZE/MiB))

export BOOT_PART_SECTOR_MARGIN=1
export BOOT_PART_TYPE='!12'       # FAT32 (LBA-addressable)
export BOOT_PART_LABEL=msdosboot
export BOOT_PART_FSTYPE=msdosfs
export BOOT_PART_FS=16            # FAT16

# Defaults for BSD partition
export BSD_PART_TYPE=freebsd
export BSD_PART_SCHEME=BSD
export BSD_PART_FSTYPE=freebsd-ufs
export BSD_PART_FSALIGN=$((64*KiB))
export BSD_PART_FSENDIAN=big
export BSD_PART_FSLABEL=rootfs

# Defaults for overlay files
export OVERLAY_FILES="boot/loader.conf etc/fstab etc/rc.conf"
export OVERLAY_FILE_MODE=644
export OVERLAY_FILE_OWNER=root
export OVERLAY_FILE_GROUP=wheel
export FIRST_BOOT_SENTINEL=/firstboot

populate_boot_partition() {
    return 0
}

create_placeholder_for_boot_partition() {
    return 0
}

setup_boot_partition() {
    create_boot_partition
    create_boot_filesystem
    mount_boot_partition
    populate_boot_partition
    unmount_boot_partition
    return 0
}

setup_bsd_partition() {
    create_bsd_partition
    create_bsd_filesystem
    mount_bsd_partition
    populate_root_partition
    copy_overlay_files
    create_placeholder_for_boot_partition
    unmount_bsd_partition
    return 0
}
