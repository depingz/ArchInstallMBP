#!/usr/bin/bash
# Defining the shell path and global variables 
SHELL_PATH=$(readlink -f $0 | xargs dirname)
source ${SHELL_PATH}/scripts/global.sh

# Please make changes to the drive based on your hardware configuration
info "Formatting the drivers..."
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda3
swapon /dev/sda3


info "Mounting the drives"
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
lsblk

info "Installing Reflector to find the best mirror list for downloading Arch Linux"
pacman -Sy --noconfirm reflector
cp /etc/pacman.d/mirrorlist  /etc/pacman.d/mirrorlist.backup
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

info "Installing all packages to get sway under wayland working with audio. Some additional useful packages are included also."
pacstrap /mnt base base-devel vim intel-ucode sudo networkmanager wpa_supplicant neofetch git alsa-utils pulseaudio-alsa coreutils linux dosfstools linux-firmware util-linux exa

info "Generating fstab for the drives."
genfstab -L -p /mnt >> /mnt/etc/fstab

info "Creating RAM Disk."
echo "tmpfs	/tmp	tmpfs	rw,nodev,nosuid,size=4G	0 0" >> /etc/fstab


info "Copying install scripts to new location"
cd /mnt 
git clone https://github.com/GoGoGadgetRepo/ArchInstallMBP
info "Entering as root into Arch Linux Install Drive"
info "You need to run install.sh to set all configurations for arch Linux system and Macbook Pro settings."
arch-chroot /mnt

umount -R /mnt
shutdown now

