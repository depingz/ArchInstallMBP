#!/usr/bin/bash
# Defining the shell path and global variables 
SHELL_PATH=$(readlink -f $0 | xargs dirname)
source ${SHELL_PATH}/bin/global.sh

# Please make changes to the drive based on your hardware configuration
# Use command fdisk -l to list all the disk and partitions on your system
info "Formatting the drivers..."
mkfs.vfat -F32 /dev/nvme0n1p3
mkfs.ext4 /dev/nvme0n1p4
mkfs.ext4 /dev/nvme0n1p5
#mkswap /dev/sda3
#swapon /dev/sda3
# Install dosfstools to be albe to format the boot partition FAT32
#pacman -S dosfstools
#mkfs -t vfat /dev/nvme0n1p3

info "Mounting the drives 1. Root, 2. Boot, 3.Home "
mount /dev/nvme0n1p4 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/nvme0n1p3 /mnt/boot
#mount -t vfat /dev/nvme0n1p3 /mnt/boot
mount /dev/nvme0n1p5 /mnt/home
lsblk

info "Installing Reflector to find the best mirror list for downloading Arch Linux"
pacman -Sy --noconfirm reflector
cp /etc/pacman.d/mirrorlist  /etc/pacman.d/mirrorlist.backup
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
#reflector -c "CN" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

info "Installing all packages to get sway under wayland working with audio. Some additional useful packages are included also."
pacstrap /mnt base base-devel vim neovim intel-ucode sudo networkmanager wpa_supplicant git alsa-utils pulseaudio-alsa coreutils dosfstools util-linux exa linux linux-firmware linux-headers linux-lts linux-lts-headers sysfsutils usbutils mtools dialog e2fsprogs

info "Generating fstab for the drives."
genfstab -L -p /mnt >> /mnt/etc/fstab

info "Creating RAM Disk."
echo "tmpfs	/tmp	tmpfs	rw,nodev,nosuid,size=3G	0 0" >> /mnt/etc/fstab


info "Copying install scripts to new location"
cp -R ${SHELL_PATH} /mnt/
info "Entering as root into Arch Linux Install Drive"
info "You need to run install.sh to set all configurations for arch Linux system and Macbook Pro settings."
arch-chroot /mnt

umount -R /mnt

