#!/bin/bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

# Available and non-preconfigured themes:
# >> Created and tested on : rofi 1.6.0-1
#
# column_circle   column_square     column_rounded     column_alt
# card_circle     card_square     card_rounded     card_alt
# dock_circle     dock_square     dock_rounded     dock_alt
# drop_circle     drop_square     drop_rounded     drop_alt
# full_circle     full_square     full_rounded     full_alt
# row_circle      row_square      row_rounded      row_alt

# Good look tweaking themes the themes

theme="row_square"
dir="/opt/nvidia-switch/nvidia-switch-ui/powermenu"

rofi_command="/opt/nvidia-switch/nvidia-switch-ui/rofi -theme $dir/$theme"

# Options
On="▶"
Off="⏸"

# Confirmation
confirm_exit() {
	rofi -dmenu\
		-i\
		-no-fixed-num-lines\
		-p "Do you want to close all applications and confirm?"\
		-theme $dir/confirm.rasi
}

# Message
msg() {
	rofi -theme "$dir/message.rasi" -e "Valid options:         yes / y / no / n "
}

# Variable passed to rofi
options="$On\n$Off"

chosen="$(echo -e "$options" | $rofi_command -p "NVIDIA Switch" -dmenu)"

ans="$(confirm_exit &)"
ans="$(echo "$ans" | awk '{print tolower($0)}')"

case $chosen in
    $On)
		if [[ $ans == "yes" || $ans == "y" ]]; then
			sudo nvidia-switch "1"
		elif [[ $ans == "no" || $ans == "n" ]]; then
			exit 0
        	else
			msg
        	fi
        ;;
    $Off)
		if [[ $ans == "yes" || $ans == "y" ]]; then
                        sudo nvidia-switch "0"
                elif [[ $ans == "no" || $ans == "n" ]]; then
                        exit 0
                else
                        msg
                fi
        ;;
esac
