
# We set POWERSAVE=1 at boot. 

# When POWERSAVE=1, the NVIDIA GPU is turned off at boot time. Also, it will turn 
# the card on before attempting to load the modules and render graphics, and turn it 
# off after the X exits. In order to it work, CONTROLLER_BUS_ID and DEVICE_BUS_ID 
# must be set correctly. IDs can be found by inspecting the output of lshw, or even 
# better, lspci -tvv tree.

echo "Fron now on, before new NVIDIA driver installations, the turn_off_gpu_at_boot.service must be turned off in systemd."
sudo cp /opt/nvidia-switch/turn_off_gpu_at_boot.service /etc/systemd/system/turn_off_gpu_at_boot.service
sudo systemctl enable turn_off_gpu_at_boot.service
