#!/usr/bin/bash
# Defining the shell path and global variables 
SHELL_PATH=$(readlink -f $0 | xargs dirname)
source ${SHELL_PATH}/bin/global.sh

info "Setting Time zone and Time"
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc

info "Setting system wide language"
sed -i '/en_GB.UTF-8'/s/^#//g /etc/locale.gen
locale-gen
cp ${SHELL_PATH}/config/etc/locale.conf /etc/

info "Setting font for vconsole"
cp ${SHELL_PATH}/config/etc/vconsole.conf /etc/

info "Setting machine name."
echo Freedom > /etc/hostname

info "Copying the modules to /etc/"
cp ${SHELL_PATH}/config/etc/modules /etc/

info "Setting environment variables for Wayland"
cp ${SHELL_PATH}//config/etc/environment /etc/

info "Giving user wheel access"
sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL'/s/^#//g /etc/sudoers

# systemd-boot Configurations
#info "Making bootable drive and configurations"
#bootctl --path=/boot install
#cp ${SHELL_PATH}/config/boot/arch.conf /boot/loader/entries/
#cp ${SHELL_PATH}/config/boot/lts.conf /boot/loader/entries/
#cp ${SHELL_PATH}/config/boot/loader.conf /boot/loader/

info "Setting the sound card index to PCA"
cp ${SHELL_PATH}/config/modprobe/snd_hda_intel.conf /etc/modprobe.d/
cp ${SHELL_PATH}/config/modprobe/i915.conf /etc/modprobe.d/
cp ${SHELL_PATH}/config/modprobe/hid_apple.conf /etc/modprobe.d/
cp ${SHELL_PATH}/config/modprobe/xhci_reset_on_suspend.conf /etc/modprobe.d/

sed -i '/Color'/s/^#//g /etc/pacman.conf

info "Type the the username for this installation:"
read USERNAME
useradd -m -g users -G wheel,sys,log,network,floppy,scanner,power,rfkill,users,video,storage,optical,lp,audio,adm,ftp,mail,git -s /bin/bash ${USERNAME}
info "Password for the user ${USERNAME}"
passwd ${USERNAME}
info "Password for root"
passwd


#bootctl set-default lts.conf
#bootctl list


info "Setting boot icon."
pacman -S --noconfirm wget librsvg libicns
wget -O /tmp/archlinux.svg https://www.archlinux.org/logos/archlinux-icon-crystal-64.svg
rsvg-convert -w 128 -h 128 -o /tmp/archlogo.png /tmp/archlinux.svg
png2icns /boot/.VolumeIcon.icns /tmp/archlogo.png
rm /tmp/archlogo.png
rm /tmp/archlinux.svg


info "Making bootable drive and configurations"
pacman -S --noconfirm grub efibootmgr
#mount -t vfat /dev/nvme0n1p3 /mnt/boot
touch /boot/mach_kernel
mkdir -p /boot/EFI/arch && touch /boot/EFI/arch/mach_kernel
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
mv /boot/EFI/arch/System/ /boot/
rm -r /boot/EFI/

#mkdir -p /boot/efi
#mount /dev/nvme0n1p3 /boot/efi

#grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
#grub-mkconfig -o /boot/grub/grub.cfg

# Alternative for Setting up the bootloader to be loaded when hold alt(option) key during macbook pro power on.
#First install the grub package from the Arch repositories
#sudo pacman -S grub

#Modify the following line in /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="quiet rootflags=data=writeback libata.force=noncq"
#sed -i -e 's/.*GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet rootflags=data=writeback libata.force=noncq"/' /etc/default/grub

#Let's set up the boot directory to work with Apple's bootloader:

#cd /boot
#mkdir -p System/Library/CoreServices
#touch mach_kernel
#Then run the following commands to create a boot.efi file
#grub-mkconfig -o /boot/grub/grub.cfg
#grub-mkstandalone -o /boot/System/Library/CoreServices/boot.efi -d /usr/lib/grub/x86_64-efi -O x86_64-efi /boot/grub/grub.cfg
#Modify the /boot/grub/grub.cfg and execute grub-mkstandalone if it does not boot
#Sometimes, the "initrd initramfs-linux.img" might be missing in the grub.cfg, add this line to fix it 

#Put the following in a new file at /boot/System/Library/CoreServices/SystemVersion.plist
cat <<EOF >>/boot/System/Library/CoreServices/SystemVersion.plist
<?xml version="1.0" encoding="utf-8"?>
<plist version="1.0">
<dict>
    <key>ProductBuildVersion</key>
    <string></string>
    <key>ProductName</key>
    <string>Linux</string>
    <key>ProductVersion</key>
    <string>Arch Linux</string>
</dict>
</plist>
EOF

sudo systemctl enable NetworkManager 
sudo systemctl enable man-db.timer
sudo systemctl enable paccache.timer

info "The system will shutdown in 5 seconds. Run post_install.sh after restart."


