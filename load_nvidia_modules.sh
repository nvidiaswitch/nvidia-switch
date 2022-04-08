#!/usr/bin/env bash

MODULES_LOAD=(nvidia nvidia_uvm nvidia_modeset nvidia_drm)
MODULES_UNLOAD=(nvidia_drm nvidia_modeset nvidia_uvm nvidia)

function load_modules {
  for module in "${MODULES_LOAD[@]}"
  do
    #Loading modules
    sudo modprobe "${module}"
  done
}

function unload_modules {
  for module in "${MODULES_UNLOAD[@]}"
  do
    #Unloading modules
    sudo modprobe -r "${module}"
  done
}


if [[ "$1" == "load" ]]
then
	load_modules

elif [[ "$1" == "unload" ]]
then
	unload_modules
fi
