#!/usr/bin/env bash

# Main script

# It restarts your display manager in order to the required configuration 
# to be loaded. If the argument is "1", then turn the nvidia on. If 
# If the argument is "0", then turn the nvidia off.

if [ $# -eq 0 ]; then
    echo 'Usage:'
    echo 'To use NVIDIA, type: sudo nvidia-switch "1"'
    echo 'To deactivate NVIDIA, type: sudo nvidia-switch "0"'
    exit
fi

if [ "$EUID" -ne 0 ]; then
        echo 'This script must be executed as root.'
  exit
fi

function turn_on {
	# Clean previous configurations
	sudo rm /etc/X11/xorg.conf
	# Use pre-configured nvidia xorg
	sudo ln -s /opt/nvidia-switch/nvidia_xorg.conf /etc/X11/xorg.conf

	# Ensure the GPU is turned on
	sudo /opt/nvidia-switch/gpu_switch.sh "on"

	# Ensure the nvidia modules is loaded
	sudo /opt/nvidia-switch/load_nvidia_modules.sh "load"

	# Configure NVIDIA display. The display_setup.sh should be executed as soon as
	# the X is launched. Preferably, use as the display manager display setup script.
	# If not using display manager, you can put it into .xsessionrc (Debian based) or
	# .xinitrc (Others).

	sudo bash -c 'cat /opt/nvidia-switch/display_setup_nvidia_only.sh > /opt/nvidia-switch/display_setup.sh'

	# The USING_NVIDIA file, is used to, in the next login, inform your X session laucher
	# (display manager, startx, xinit) to turn off your NVIDIA Graphics card.
	# It's only used by open_nvidia_session.sh script.

	bash -c 'echo "1" > "/opt/nvidia-switch/USING_NVIDIA"'
	
	# Add Nvidia vaapi and vdpau drivers to users environment
	
	bash -c 'echo "" > "/home/$USER_WHO_SUDOED/.config/envionment.d/vidaccel.conf"'
	bash -c 'echo "LIBVA_DRIVER_NAME=nvidia" >> "/home/$USER_WHO_SUDOED/.config/envionment.d/vidaccel.conf"'
	bash -c 'echo "VDPAU_DRIVER=nvidia" >> "/home/$USER_WHO_SUDOED/.config/envionment.d/vidaccel.conf"'
}

function turn_off {
	# Clean previous configurations
	sudo rm /etc/X11/xorg.conf
	# Configure Intel display
	sudo bash -c 'echo "" > /opt/nvidia-switch/display_setup.sh'

	# Use pre-configured intel xorg
	sudo ln -s /opt/nvidia-switch/intel_xorg.conf /etc/X11/xorg.conf

	# Inform dusplay manager you will not use nvidia so that you can unload 
	# nvidia-modules and put your NVIDIA to rest a bit. 
	sudo bash -c 'echo "0" > "/opt/nvidia-switch/USING_NVIDIA"'
	
	# Add Intel vaapi and vdpau drivers to users environment
	
	bash -c 'echo "" > "/home/$USER_WHO_SUDOED/.config/envionment.d/vidaccel.conf"'
	bash -c 'echo "LIBVA_DRIVER_NAME=iHD" >> "/home/$USER_WHO_SUDOED/.config/envionment.d/vidaccel.conf"'
	bash -c 'echo "VDPAU_DRIVER=va_gl" >> "/home/$USER_WHO_SUDOED/.config/envionment.d/vidaccel.conf"'
}


if [[ "$1" == "1" ]]; then
    turn_on
elif [[ "$1" == "0" ]]; then
    turn_off
else
    	echo 'Usage:'
    	echo 'To use NVIDIA, type: sudo nvidia-switch "1"'
    	echo 'To deactivate NVIDIA, type: sudo nvidia-switch "0"'
	exit
fi

# Restart your display manager. This is executed in order to the new configuration
# done to be read. If it is not restarted, it's not guaranteed the script will work.
# By implementation choices, this is done as soon this script is lauched. This way, 
# The user will not forget that he have turned on the graphics card; it's more intuitive.

# gdm is quite bad in with this script. I suggest using lightdm or sddm. It's possible to use
# lightdm, or sddm, with gnome or any other desktop environment. Just a metter of installing
# the packages.

sudo systemctl restart display-manager.service
