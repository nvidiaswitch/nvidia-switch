# nvidia-switch

NVIDIA switch is a tool that automates the shifts between your NVIDIA Graphics
Card and your Intel without needing to reboot your computer or changing TTY. 
This script let all the X configurations to be done by your Display Manager, 
which improves security a bit and let the things more intuitive. Also, it has
 power management features similar to nvidia-xrun.


# First, set up the Bus ID information

In order to make power management features work properly, you need to make sure
that Bus IDs in `bus_id` file are correctly set for both the
NVIDIA graphic card and the PCI express controller that hosts it. You should be
able to find both the ids in the `lspci -tv` and `lspci` output mesages 
as follows.

First, open therminal and type 

	lspci

After, open the `bus_id` file inside the nvidia-switch directory. The `DEVICE_BUS_ID`
 variable in the `bus_id` file corresponds to the NVIDIA graphics 
card ID. The output of `lspci` must contain a lot of Bus IDs, but the ones that matters
are the NVIDIA ones, and is displayed similarly as follows

![](https://github.com/nvidiaswitch/nvidia-switch/blob/main/pictures/lspci_2.png)

This way the Bus ID must be `01:00.0`. The correct format must be put similarly to 

	DEVICE_BUS_ID=0000:01:00.0

Note that, in some cases, like in mine, it's possible to have two, or more, NVIDIA devices.
In such cases, you can put the second NVIDIA device in the `SUB_DEVICE_BUS_ID`, and its format is similar
to `DEVICE_BUS_ID` format, that is, 

	SUB_DEVICE_BUS_ID=0000:01:00.1

Now, we need to find the Bus ID of the PCI express controller that hosts your NVIDIA graphics
 card with the `lspci -tv`. For example, my `lspci -tv` outputs have the following snippet:

![](https://github.com/nvidiaswitch/nvidia-switch/blob/main/pictures/lspci.png)

Note that, inside the squares I have the numbers `0000:00:01.0`. This is the NVIDIA
Graphics card parent in the `lspci -tv` tree, and is the controller that hosts my NVIDIA
device. Hence, the `CONTROLLER_BUS_ID` is given by 	

	CONTROLLER_BUS_ID=0000:00:01.0

Also, under the same controller we have only two devices, the NVIDIA ones, which 
confirms that only two devices must be turned off, as the previous steps suggested.

The Bus IDs are used by the systemd service to completely remove the card from the kernel device tree.
This means that the NVIDIA devices won't even show in lspci output as soon as the laptop is
turned on, and this will prevent the NVIDIA modules to be loaded, so that we can take advantage 
of the kernel power management features to keep the card switched off. On the other hand, as soon you need 
your NVIDIA, the graphic card is turned on, and the modulues will be loaded again, allowing
the use of the full performance of the NVIDIA Graphics Card.

> As a note, we only turn off the NVIDIA Graphics card at system startup. This is done to prevent 
the system locks after switching between video cards.

The service can be enabled by running this command inside the nvidia-switch directory:

	sudo bash remove_nvidia_from_kernel.sh


# Instalation

After the Bus ID's is setted up correcly, just type on terminal 

	echo "$(whoami)" | xargs sudo bash ./installer.sh

If nothing comes wrong, a joke will be printed in your screen with no warnings. =) 

# Usage

The nvidia-switch script is as simple as it seems. To let your NVIDIA render games,
you just need to open the terminal and type: 

	sudo nvidia-switch "1"

To let our Intel graphics card to render simple programs, and let the power management
tool to run, you just need to open the terminal and type: 

	sudo nvidia-switch "0"
	
> Note that using nvidia-switch closes all your applications in your session. 
> This is done because there is no way of starting a new X session using the display 
> manager without closing all programs inside your session, i.e., in a secure way, 
> without closing your session. Hence, before using nvidia-switch, please, close all 
> your applications manually. 


# On the similarities with nvidia-xrun

This scripts is havely based on [nvidia-xrun](https://github.com/Witko/nvidia-xrun/) ideas, 
but it has been organized in a way it was possible to execute the script without changing TTY. 
In summary, this script fixes https://github.com/Witko/nvidia-xrun/issues/4. As such, this 
script has no warranty, see https://github.com/Witko/nvidia-xrun/blob/master/LICENSE, and follows the 
same copyright. 

# Disclosure

I won't spend much time on this repo. This repo was made for my personal use, but since 
I find this useful, I am sharing it with everyone.
