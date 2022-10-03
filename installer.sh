#!/usr/bin/env bash

# This scripts is based on the description of:
# https://wiki.archlinux.org/title/NVIDIA_Optimus#Use_NVIDIA_graphics_only

function install_gdm() { \

        sudo cp "/opt/nvidia-switch/default/optimus.desktop" "/usr/share/gdm/greeter/autostart/optimus.desktop"
        sudo cp "/opt/nvidia-switch/default/optimus.desktop" "/etc/xdg/autostart/optimus.desktop"

        if [[ -f "/etc/gdm3/daemon.conf"  ||  -f "/etc/gdm/custom.conf" ]]; then

                if [[ -f "/etc/gdm3/daemon.conf" ]]; then
                	sudo sed -i '/WaylandEnable/s/^#//g' "/etc/gdm3/daemon.conf"
                fi

                if [[ -f "/etc/gdm/custom.conf" ]]; then
                	sudo sed -i '/WaylandEnable/s/^#//g' "/etc/gdm/custom.conf"
                fi
        else
                if [[ -d "/etc/gdm3" ]]; then
                	sudo cp "/opt/nvidia-switch/default/daemon.conf" "/etc/gdm3/daemon.conf"
                fi

                if [[ -d "/etc/gdm" ]]; then
                	sudo cp "/opt/nvidia-switch/default/daemon.conf" "/etc/gdm/custom.conf"
                fi

                if [[ ! -f "/etc/gdm3/daemon.conf" || ! -f "/etc/gdm/custom.conf" ]]; then
                	echo "You seem not to have the gdm system config directory. Find where is it located in order to disable Wayland."
                fi
        fi

}

function install_lightdm() { \

	if [ -f "/etc/lightdm/lightdm.conf" ]; then
		sed -i ':a;N;$!ba; s/\[Seat:\*\]/\[Seat:\*\]\ndisplay-setup-script=\/opt\/nvidia-switch\/display_setup.sh/2' "/etc/lightdm/lightdm.conf"
        	awk '!a[$0]++' '/etc/lightdm/lightdm.conf' | sudo tee '/etc/lightdm/lightdm.conf' > /dev/null
	else
		echo "You seem not to have the lightdm system config file. Find where is it located and set display-setup-script=/opt/nvidia-switch/display_setup.sh."
	fi
}

function install_sddm() { \

	if [ -d "/usr/share/sddm/scripts" ]; then
		sudo cp "/opt/nvidia-switch/default/Xsetup" "/usr/share/sddm/scripts"
	else
		echo "You seem not to have sddm config directory."
	fi
}


if [ $# -eq 0 ]; then
    echo 'Usage:'
    echo 'echo "$(whoami)" | xargs sudo bash ./installer.sh'
    exit
fi

if [ "$EUID" -ne 0 ]; then
        echo 'Usage:'
        echo 'echo "$(whoami)" | xargs sudo bash ./installer.sh'
  exit
fi

cd "$(dirname "$0")"

# 'sudo whoami' does not work. Up to my knowledge, there is no reliable way of knowing
# which user used sudo inside a script. Hence, the user name is expected as an argument of the
# script.
USER_WHO_SUDOED="$1"

#################################################################################
# FOR SANITY CHECK, SEE IF THE USER TYPED THE AT LEAST A VALID USER.
if ! getent passwd "$USER_WHO_SUDOED" > /dev/null 2>&1; then
        echo 'You seem to have given a wrong username, and manually.'
        echo "If you dont wan't to give a name manually, try:"
        echo 'echo "$(whoami)" | xargs sudo bash ./installer.sh'
        exit
fi
#################################################################################

# Copy archives
if [ -d "/opt"  ]; then
	if [ ! -d "/opt/nvidia-switch/"  ]; then
	sudo mkdir "/opt/nvidia-switch/"
	fi
else
	mkdir "/opt"
	mkdir "/opt/nvidia-switch/"
fi

find . -iname "*.sh" -exec bash -c 'chmod +x "$0"' {} +

cp -r ./ "/opt/nvidia-switch/" 2>/dev/null

# Make a Intel configuration equal to the already configured
if [ -f "/etc/X11/xorg.conf" ]; then
	echo "Your xorg.conf config in Intel mode is now: "
	cat "/etc/X11/xorg.conf" | tee "/opt/nvidia-switch/intel_xorg.conf"
fi

if [ -d "/etc/X11/xorg.conf.d" ]; then
	if [ ! -z "$(ls -A /etc/X11/xorg.conf.d)" ]; then
	cat /etc/X11/xorg.conf.d/* | tee -a "/opt/nvidia-switch/intel_xorg.conf"
	fi
fi

if [ ! -d "/etc/nvidia-switch" ]; then
	sudo mkdir "/etc/nvidia-switch"
fi

if [ ! -f "/etc/nvidia-switch/bus_id" ]; then
	sudo cp "/opt/nvidia-switch/bus_id" "/etc/nvidia-switch"
fi

# Configure the display manager to be setted up for nvidia-switch
DISPLAYMANAGER="$(cat /etc/X11/default-display-manager | awk -F"/" '{print $NF}')"

if [[ "$DISPLAYMANAGER" == lightdm* ]]; then
	install_lightdm
elif [[ "$DISPLAYMANAGER" == sddm* ]]; then
	install_sddm
elif [[ "$DISPLAYMANAGER" == gdm* ]]; then
	install_gdm
else
	echo "You seem to possess a display manager we don't know how to configure, if you have one."
	echo "If you don't have one, you might need to manually configure your display"\
	" with the display_setup.sh script in the proper place."
  	echo "Some options are to put the xrandr commands in xprofile, xsessionrc or in xinitrc files."
  	echo "Regarding this script, we accepet any pull requests treating different uses of the display_setup.sh script."
fi

# Copy the archive to the bin and sbin directories
cp "/opt/nvidia-switch/nvidia_switch.sh" "/usr/local/bin/nvidia-switch"
cp "/opt/nvidia-switch/nvidia_switch.sh" "/usr/local/sbin/nvidia-switch"
cp "/opt/nvidia-switch/nvidia-switch-ui/nvidia_switch_ui.sh" "/usr/local/bin/nvidia-switch-ui"
cp "/opt/nvidia-switch/nvidia-switch-ui/nvidia_switch_ui.sh" "/usr/local/sbin/nvidia-switch-ui"

# Give the archives execution permission:
sudo chmod +x "/usr/local/sbin/nvidia-switch"
sudo chmod +x "/usr/local/bin/nvidia-switch"
sudo chmod +x "/usr/local/bin/nvidia-switch-ui"
sudo chmod +x "/usr/local/sbin/nvidia-switch-ui"

# Adding the script /opt/nvidia-switch/open_nvidia_session.sh to run at session startup.
if [ -f "/etc/debian_version" ]; then
	if [ ! -f "/home/$USER_WHO_SUDOED/.xsessionrc" ]; then
    		sudo touch "/home/$USER_WHO_SUDOED/.xsessionrc"
    		sudo chown "$USER_WHO_SUDOED:$USER_WHO_SUDOED" "/home/$USER_WHO_SUDOED/.xsessionrc"
	fi

	if [ -z "$(grep 'sudo /opt/nvidia-switch/open_nvidia_session.sh &' "/home/$USER_WHO_SUDOED/.xsessionrc")" ]; then
	echo '/opt/nvidia-switch/open_nvidia_session.sh &' >> "/home/$USER_WHO_SUDOED/.xsessionrc"
	fi
else
	echo "You are not using a Debian-based system."
	echo "You need to add the script /opt/nvidia-switch/open_nvidia_session.sh to run at startup of your user X session."
fi

# Make a folder in the users home for per user environment variables and add a file to it
if [ ! -d "/home/$USER/.config/environment.d" ]; then
	mkdir "/home/$USER/.config/environment.d" && touch "/home/$USER/.config/environment.d/vidaccel.conf"
fi

# Make a simple systemd service to reset the xorg.conf at boot. This prevents black
# and flickering screens after the laptop reboots with NVIDIA on.
sudo cp "/opt/nvidia-switch/reset_xorg_conf.service" "/etc/systemd/system/"
sudo systemctl enable reset_xorg_conf.service

#####################################################################################
# WARNING: DO NOT MESS WITH THIS PORTION OF THE SCRIPT. ANY ERROR ADDED HERE CAN    #
# PREVENT YOU FROM USING SUDO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                          #
# WITHOUT A ROOT PASSWORD, IT WILL BE NEEDED TO USE BASH AS INIT SYSTEM TO FIX THE  #
# MESS DONE. A QUITE DELICATE SITUATION FOR NOVICES.                                #
#####################################################################################
	sudo touch "/etc/sudoers.d/nvidia_switch"
	sudo chmod +w "/etc/sudoers.d/nvidia_switch"

	sudo touch "/opt/nvidia-switch/tmp_nvidia_switch"
	sudo chmod +w "/opt/nvidia-switch/tmp_nvidia_switch"
	echo "$USER_WHO_SUDOED    ALL=(ALL) NOPASSWD: /usr/local/bin/nvidia-switch, /usr/local/sbin/nvidia-switch, /opt/nvidia-switch/open_nvidia_session.sh, /opt/nvidia-switch/gpu_switch.sh, /opt/nvidia-switch/load_nvidia_modules.sh" | sudo tee '/opt/nvidia-switch/tmp_nvidia_switch' > /dev/null
	NEW_RULE="$(cat /opt/nvidia-switch/tmp_nvidia_switch)"

	#Checks if the user's rule already exist before modifying the additional sudoers file
	if [[ -z "$( grep "$NEW_RULE" /etc/sudoers.d/nvidia_switch )"  ]]; then
	echo "$NEW_RULE" | sudo tee -a '/etc/sudoers.d/nvidia_switch' > /dev/null
	fi
	sudo chmod 0440 "/etc/sudoers.d/nvidia_switch"
	sudo rm "/opt/nvidia-switch/tmp_nvidia_switch"
# END WARNING
#################################################################################

echo "It has broken your laptop successfully. =P"
