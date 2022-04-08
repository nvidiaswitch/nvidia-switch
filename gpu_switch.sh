#!/usr/bin/env bash

# When POWERSAVE=1, the NVIDIA GPU is turned off at boot time. Also, it will turn 
# the card on before attempting to load the modules and render graphics, and turn it 
# off after the X exits. In order to it work, CONTROLLER_BUS_ID and DEVICE_BUS_ID 
# must be set correctly. IDs can be found by inspecting the output of lshw, or even 
# better, lspci -tvv tree.

# Load bus Id's
. /etc/nvidia-switch/bus_id

function turn_off_gpu {
  # The ideia of the script is to remove the Nvidia from the Kernel only if the
  # The GPU is set to be removed at boot time, and only be removed at boot time.
  # Otherwise, powersave is prefered. Two reasons can be given. Fist, A GPU being
  # automatically removed can cause some issues with Nvidia  drivers instalation.
  # That's the why the service turn_off_gpu_at_boot.service must be disabled for
  # new nvidia driver instalation. The second reason is that the system hangs if
  # the GPU is put off after its use. Hence, it can only be totally turned off at boot time.

  # TIP: If it the laptop is not plugged, after gaming, is better to reboot the laptop
  # to save battery, but you are not restricted to it; just better.

  if [[ "$POWERSAVE" == '1' ]]; then
    #Removing Nvidia bus from the kernel
    eval "sudo tee /sys/bus/pci/devices/${DEVICE_BUS_ID}/remove <<<1"
    eval "sudo tee /sys/bus/pci/devices/${SUB_DEVICE_BUS_ID}/remove <<<1"
  else
    #Enabling powersave for the graphic card
    eval "sudo tee /sys/bus/pci/devices/${DEVICE_BUS_ID}/power/control <<<auto"
  fi

  #Enabling powersave for the PCIe controller
  eval "sudo tee /sys/bus/pci/devices/${CONTROLLER_BUS_ID}/power/control <<<auto"
}

function turn_on_gpu {
  #Turning the PCIe controller on to allow card rescan
  eval "sudo tee /sys/bus/pci/devices/${CONTROLLER_BUS_ID}/power/control <<<on"

  #Waiting 1 second
  eval "sleep 1"

  if [[ ! -d /sys/bus/pci/devices/${DEVICE_BUS_ID} ]]; then
    #Rescanning PCI devices
    eval "sudo tee /sys/bus/pci/rescan <<<1"
    #Waiting ${BUS_RESCAN_WAIT_SEC} second for rescan
    eval "sleep ${BUS_RESCAN_WAIT_SEC}"
  fi

  #Turning the card on
  eval "sudo tee /sys/bus/pci/devices/${DEVICE_BUS_ID}/power/control <<<on"
}

if [[ "$1" == "on" ]]
then
turn_on_gpu
elif [[ "$1" == "off" ]]
then
turn_off_gpu
fi
