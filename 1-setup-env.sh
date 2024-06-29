hostname=ks-pc-l
swap=/dev/sdb1
swapname=archswap

efi=/dev/sdb3
efiname=archefi

main=/dev/sdb4
mainname=archmain

umount -R /mnt

mkswap -L $swapname $swap
swapon $swap
mkfs.ext4 -L $mainname $main
mount $main /mnt
mkfs.fat -F 32 -n $efiname $efi
mount --mkdir $efi /mnt/efi
pacstrap /mnt base linux linux-firmware efibootmgr nano networkmanager iwd grub amd-ucode man-db man-pages texinfo sudo wpa_supplicant dhcpcd linux-headers base-devel libx11 libxft libxinerama freetype2 kitty thunar xorg neofetch htop xfce4-power-manager mesa xorg xorg-server xorg-apps xorg-drivers xorg-xkill xorg-xinit xterm base-devel libx11 libxft libxinerama freetype2 binutils dosfstools linux-headers noto-fonts-emoji usbutils xdg-user-dirs alsa-plugins alsa-utils autoconf automake awesome-terminal-fonts bash-completion bind bison bluez bluez-libs bluez-utils bridge-utils btrfs-progs celluloid cmatrix code cronie cups dialog dmidecode dnsmasq dtc efibootmgr egl-wayland exfat-utils flex fuse2 fuse3 fuseiso gamemode gcc gimp gparted gptfdisk grub-customizer gst-libav gst-plugins-good gst-plugins-ugly haveged htop jdk-openjdk kitty libdvdcss libtool lsof lutris lzop m4 make ntfs-3g ntp openbsd-netcat openssh os-prober p7zip papirus-icon-theme patch picom pkgconf powerline-fonts pulseaudio pulseaudio-alsa pulseaudio-bluetooth python-notify2 python-psutil python-pyqt5 python-pip qemu snap-pac snapper swtpm terminus-font traceroute ttf-droid ttf-hack ttf-roboto ufw unrar unzip virt-manager virt-viewer which zip zsh zsh-syntax-highlighting zsh-autosuggestions bridge-utils mangohud vde2
genfstab -L /mnt >> /mnt/etc/fstab
echo $hostname > /mnt/etc/hostname
cp -rfv 2-setup-chroot.sh /mnt/root/

read -p "Do you want to chroot into the system and run setup-chroot.sh? (yes/no): " confirm_chroot
if [[ "${confirm_chroot,,}" == "yes" || "${confirm_chroot,,}" == "y" ]]; then
    arch-chroot /mnt /bin/bash /root/2-setup-chroot.sh
else
    echo "Chroot and script execution skipped."
    echo "Run setup-chroot.sh, once you have chrooted in."
fi
