swap=/dev/sdb1
efi=/dev/sdb4
main=/dev/sdb3
USERNAME=ks

sed -i 's/^#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

timedatectl --no-ask-password set-timezone Europe/London
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_GB.UTF-8" LC_TIME="en_GB.UTF-8"
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
localectl --no-ask-password set-keymap uk

sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm --needed
pacman -S wine-gecko wine-mono zoom ttf-meslo ocs-url plymouth-git sddm-nordic-theme-git snapper-gui-git wine steam synergy winetricks autojump brave-bin dxvk-bin github-desktop-bin lightly-git lightlyshaders-git mangohud-common nerd-fonts-fira-code nordic-darker-standard-buttons-theme nordic-darker-theme nordic-kde-git nordic-theme ocs-url plymouth-git

proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type}; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
    proc_ucode=intel-ucode.img
elif grep -E "AuthenticAMD" <<< ${proc_type}; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
    proc_ucode=amd-ucode.img
fi

gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed nvidia
	nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif grep -E "Intel Corporation UHD" <<< ${gpu_type}; then
    pacman -S --needed --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi

groupadd libvirt
useradd -m -G wheel,libvirt -s /bin/bash $USERNAME
echo "user (${USERNAME}) created, home directory created, added to wheel and libvirt group, default shell set to /bin/bash"
echo "Enter passwd for $USERNAME"
passwd $USERNAME
cd ~
systemctl enable NetworkManager.service
echo "NetworkManager enabled"
systemctl enable bluetooth
echo "Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "Avahi enabled"
echo "Installing grub"
grub-install --efi-directory=/efi $efi
echo "Installed grub. Making config."
grub-mkconfig -o /boot/grub/grub.cfg
echo "Made grub.cfg"
pacman -Syy --noconfirm --needed
pacman -S --noconfirm --needed xorg yay networkmanager dhclient base-devel libx11 libxft libxinerama freetype2 kitty thunar
systemctl enable --now NetworkManager