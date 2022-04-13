#!/usr/bin/env bash

# This scripts is based on the description of:
# https://wiki.archlinux.org/title/NVIDIA_Optimus#Use_NVIDIA_graphics_only

function uninstall_gdm() { \

        sudo rm "/usr/share/gdm/greeter/autostart/optimus.desktop"
        sudo rm "/etc/xdg/autostart/optimus.desktop"

        if [[ -f "/etc/gdm3/daemon.conf"  ||  -f "/etc/gdm/custom.conf" ]]; then

                if [[ -f "/etc/gdm3/daemon.conf" ]]; then
                	sudo sed -i '/WaylandEnable/s/^/#/g' "/etc/gdm3/daemon.conf"
                fi

                if [[ -f "/etc/gdm/custom.conf" ]]; then
                	sudo sed -i '/WaylandEnable/s/^/#/g' "/etc/gdm/custom.conf"
                fi
        fi

}

function uninstall_lightdm() { \

	if [ -f "/etc/lightdm/lightdm.conf" ]; then
		sed -i ':a;N;$!ba; s/\[Seat:\*\]\ndisplay-setup-script=\/opt\/nvidia-switch\/display_setup.sh/\[Seat:\*\]/g' "/etc/lightdm/lightdm.conf"
	fi
}

function uninstall_sddm() { \

	if [ -d "/usr/share/sddm/scripts" ]; then
		sudo rm "/opt/nvidia-switch/default/Xsetup"
	fi
}

DISPLAYMANAGER="$(cat /etc/X11/default-display-manager | awk -F"/" '{print $NF}')"

if [[ "$DISPLAYMANAGER" == lightdm* ]]; then
	uninstall_lightdm
elif [[ "$DISPLAYMANAGER" == sddm* ]]; then
	uninstall_sddm
elif [[ "$DISPLAYMANAGER" == gdm* ]]; then
	uninstall_gdm
fi

sudo rm "/etc/X11/xorg.conf"
sudo cp "/opt/nvidia-switch/intel_xorg.conf" "/etc/X11/xorg.conf"
sudo systemctl disable turn_off_gpu_at_boot.service
sudo systemctl disable reset_xorg_conf.service
sudo rm "/usr/local/bin/nvidia-switch"
sudo rm "/usr/local/bin/nvidia-switch-ui"
sudo rm "/usr/local/sbin/nvidia-switch-ui"
sudo rm "/usr/local/sbin/nvidia-switch"
sudo rm "/etc/systemd/system/reset_xorg_conf.service"
sudo rm "/etc/systemd/system/turn_off_gpu_at_boot.service"
sudo rm "/etc/sudoers.d/nvidia_switch"
sudo rm -r "/opt/nvidia-switch/"
