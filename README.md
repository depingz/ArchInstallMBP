# Macbook Pro 11,4 {Status = Development}

You can follow the 'Readme.me' file and carry the set-up step by step or run the automated scripts. 
There are 3 scripts (pre, post and package install).

## Installation Instructions
This is modified to dual boot macos and arch linux.

### Fix unable to boot from USB Install Media
When arch linux boot option shows, Press e to edit the parameters, add 
```
intel_iommu=on
```

### Setting the font

Macbook Pro have HiDPI which makes reading the text hard. To make it readable.

```{bash}
setfont latarcyrheb-sun32
```
If the system is not connected to internet through LAN, it can be connected using wifi
```
iwctl
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "ssid"
```

Git is not available in the start which can be installed using:

```{bash}
pacman -Sy git
```

### Disk Preparation 

Following is my disk set-up. I am choosing not to create a special partition for swap file. If swap is required in the future, I plan to create a swap file.

| Size | Mount Point | Format | Partition Code |
|---|---|---|---|
| 300M | /boot | FAT32 | UEFI Boot Partition |
| 200G | / | ext4 | Linux File System |
| * | /home | ext4 | Linux Home System |

```{bash}
cgdisk /dev/nvme0n1
```

#### Formatting the Drives

```{bash}
mkfs.vfat -F32 /dev/nvme0n1p3
mkfs.ext4 -l main /dev/nvme0n1p4
```

### Mounting drives for install
```{bash}
mount /dev/nvme0n1p4 /mnt
mkdir /mnt/boot && mount /dev/nvme0n1p3 /mnt/boot
lsblk 
```

**lsblk** allows you to look at the structure of the disk.

### Installing Arch Linux files

```{bash}
pacstrap /mnt base base-devel vim intel-ucode sudo networkmanager wpa_supplicant  git util-linux sway wlroots wayland swaylock swayidle termite mako grim slurp wl-clipboard
```

| Package | Purpose |
|---|---|
| base | The required one with base utils. |
| base-devel | Development tools |
| neovim | Text Editor |
| intel-ucode | |
| sudo | To run superuser commands without changing the suer |
| networkmanager | Package to manage network connections |
| wpa_supplicant | |
| git | |
| util-linux | |
| sway | Wayland based tiling windows manager and 100% compatible with i3 |
| wlroots | Required by wayland |
| wayland | The new Xorg compositor |
| swaylock | Sway's addon to allow system lock down with idle |
| swayidle | | 
| termite | Terminal application |
| mako | Notification Daemon |
| grim + slurp | Screen shot |
| wl-clipboard | Clipboard copy/paste |

#### Configuring fstab

```{bash}
genfstab -L -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```
## Running Scripts 
There are 3+ scripts that need to be run in each stage.
| Script Name | Stage | Purpose |
| --- | --- | --- |
| post_install.sh | Preparation | Install basic required packages |
| install.sh | Install | Basic Configuration and Bootup setup |
| post_install.sh | Post Install | Starting Services for day and patching |
| sway.sh | Desktop Environment | Setting up Sway DE - Development |
| gnome.sh | Desktop Environment | Setting up Gnome DE - Development |
| kde.sh | Desktop Environment | Setting up KDE DE - Development |

https://bugzilla.kernel.org/show_bug.cgi?id=193121
