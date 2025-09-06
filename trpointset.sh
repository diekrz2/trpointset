#!/bin/bash


# Script that helps set TrackPoint speed on ThinkPad keyboards.
# Copyright (C) 2025 diekrz2 diekrz2@protonmail.com 

# "trpointset" is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# "trpointset" is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.


# function that checks if bash is being used

check_bash(){

if [ -z "$BASH_VERSION" ]; then
   echo "This script requires bash to run. Try again using bash."
   echo
   exit 1
fi
}

# function that checks if 'xinput' is installed. If not installed, the installation via apt will start 

install_xinput(){

	echo "Checking if 'xinput' is already installed..."
	echo
	sleep 2
	
	if ! command -v xinput &>/dev/null; then
		
		echo "'xinput' is not installed. Installing..."
		echo
		sleep 2

		sudo apt update
		sudo apt install xinput -y

		echo

		if [ $? -eq 0 ]; then
			echo "'xinput' has been installed."
			echo
		else
			echo "Error during 'xinput' installation"
			echo
			exit 1
		fi
	else
		echo "'xinput' is already installed"
		echo
		sleep 2
	fi
}

# function that finds the 'id' number of your Trackpoint. The id is needed to associate the acceleration with it

find_id(){
	
    local tp_id
    tp_id=$(xinput | perl -ne 'if(/TrackPoint.*id=(\d+)/) { print $1; }')

    if [ -z "$tp_id" ]; then
        echo "No TrackPoint found. This script is designed for ThinkPad keyboards."
        echo
        exit 1
    fi

    echo "TrackPoint ID found: $tp_id"
    echo
    
	# Ask the user for an acceleration value

    echo "Enter a value between -1.0 and +1.0 (the default value of your TrackPoint is probably 0.0):"
    echo
    read -r acc_val
    echo

    # Apply the acceleration value
    
    xinput --set-prop "$tp_id" 'libinput Accel Speed' "$acc_val"
    echo "TrackPoint acceleration has been set to $acc_val."
    echo
    
    enable_autostart "$tp_id" "$acc_val"
}

# Configure the new acceleration to start automatically. Accepts "y", "Y", "n" and "N" as answers

enable_autostart(){
	
	local tp_id="$1"
	local acc_val="$2"
	local startup_file="$HOME/.e/e/applications/startup/startupcommands"

	echo "Do you want to enable this acceleration on startup? (Y/n)"
	echo
	read -r autostart
	echo

	if [[ "$autostart" =~ ^[yY]$ ]]; then
		 mkdir -p "$(dirname "$startup_file")"
		 touch "$startup_file"

	   if ! grep -Fq "xinput --set-prop $tp_id 'libinput Accel Speed' $acc_val" "$startup_file"; then
		echo "xinput --set-prop $tp_id 'libinput Accel Speed' $acc_val" >> "$startup_file"
		echo
		echo "The new acceleration has been configured to start automatically"
		echo
		
		fi

	elif [[ "$autostart" =~ ^[nN]$ ]]; then
		echo "Operation cancelled"
		echo
	else
		echo "Invalid input. Please respond with 'y' or 'n'."
		echo
		
	fi
}

# Main function to execute the other functions in order.

main(){
	
	check_bash
	install_xinput
	find_id
}

main








