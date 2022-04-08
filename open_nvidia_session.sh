#!/usr/bin/env bash

USING_NVIDIA="$(cat "/opt/nvidia-switch/USING_NVIDIA" 2> /dev/null)"

case $USING_NVIDIA in
0) sudo /opt/nvidia-switch/load_nvidia_modules.sh "unload"; sudo /opt/nvidia-switch/gpu_switch.sh "off" ;;
1) export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/lib/x86_64-linux-gnu/vdpau:${LD_LIBRARY_PATH}; export VK_ICD_FILENAMES=/etc/vulkan/icd.d/nvidia_icd.json ;;
*) echo "Invalid option!" ;;
esac
