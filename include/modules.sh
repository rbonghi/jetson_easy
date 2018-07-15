#!/bin/bash
# Copyright (C) 2018, Raffaello Bonghi <raffaello@rnext.it>
# All rights reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its 
#    contributors may be used to endorse or promote products derived 
#    from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

MODULES_LIST=""
MODULES_FOLDER="modules"
# Default name setup jetson_easy
MODULES_CONFIG_NAME="setup.txt"
# Absolute path configuration file
MODULES_CONFIG_PATH=""
MODULES_CONFIG_FILE=""
# File check if is in sudo mode
MODULES_SUDO_ME_FILE="jetson_easy.sudo"
# Default configuration this code start not in remote mode
MODULE_REMOTE=0

# --------------------------------
# LOAD_MODULES
# --------------------------------

modules_sort()
{
    local MODULES_LIST_ARRAY
    # transform list in array
    IFS=$':' MODULES_LIST_ARRAY=($MODULES_LIST)
    # sort the array
    IFS=$'\n' MODULES_LIST_ARRAY=($(sort <<<"${MODULES_LIST_ARRAY[*]}"))
    # Re arrange array in list with delimiter ":"
    MODULES_LIST=$(echo ${MODULES_LIST_ARRAY[*]} | sed -e "s/ /:/g")
}

modules_load_default()
{
    # Read modules
    for folder in $MODULES_FOLDER/* ; do
        if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE_NAME=$(echo $folder | cut -f2 -d "/")
        local FILE="$folder"/$FILE_NAME.sh
            if [ -f $FILE ] ; then
                # Unset save function
                unset -f script_load_default
                # Load source
                source "$FILE"
                 # If a default module
                if [ $MODULE_DEFAULT -eq 1 ] ; then
                    MODULES_LIST+="$FILE_NAME:"
                fi
                # Check if exist the function
                if type script_load_default &>/dev/null
                then
                    script_load_default
                    # Load initialization variable function
                    # echo "Load Default variable for: $MODULE_NAME"
                fi
            fi
        fi
    done
    # Sort all modules
    modules_sort
}

# Load configuration return status:
# 0 - Load file or folder
# 1 - Load default
modules_load_config()
{
	#Default load setup config name folder
	local MODULES_CONFIG=$MODULES_CONFIG_NAME
    if [ ! -z $1 ] ; then
        MODULES_CONFIG=$1
    fi
    local config_path=""
    # Load config path
    if [[ "$MODULES_CONFIG" = /* ]]; then
        # Save absolute path
        config_path="$MODULES_CONFIG"
    else
        # Get absolute path from local path
        config_path="$USER_PWD/$MODULES_CONFIG"
    fi
    
    # Check configuration file
	if [[ -d $config_path ]]; then
		# If is a directory check if exist file MODULES_CONFIG_NAME (standard name is: setup.txt)
		local setup_file=$config_path/$MODULES_CONFIG_NAME
		# Check if exist config file
		if [[ -f $setup_file ]]; then
			#echo "$setup_file is a jetson easy folder"
			# Set variables
			MODULES_CONFIG_PATH=$(realpath $config_path)
			MODULES_CONFIG_FILE=$(realpath $setup_file)
			return 0
		#else
			#echo "$setup_file is not a jetson easy folder"
		fi
	elif [[ -f $config_path ]]; then
		#echo "$config_path is a jetson easy file"
		# Set variables
		MODULES_CONFIG_PATH=$(realpath $USER_PWD)
		MODULES_CONFIG_FILE=$(realpath $config_path)
		return 0
	#else
		#echo "$config_path is not valid"
	fi
	# Set default configuration
	MODULES_CONFIG_PATH="$USER_PWD"
	MODULES_CONFIG_FILE="$config_path"
    #echo "MODULES_CONFIG_PATH=$MODULES_CONFIG_PATH"
    #echo "MODULES_CONFIG_FILE=$MODULES_CONFIG_FILE"
    return 1
}

modules_load()
{
    if [ -f $MODULES_CONFIG_FILE ] ; then
        # echo "Setup \"$MODULES_CONFIG_FILE\" found!"
        # Load all default values
        modules_load_default
        # Load and overwrite with setup file
        source $MODULES_CONFIG_FILE
        # Sort all modules
        modules_sort
    else
        # echo "Setup \"$MODULES_CONFIG_FILE\" NOT found! Load default"
        modules_load_default
    fi
}

modules_save()
{
    echo "# Configuration Biddibi boddibi Boo" > $MODULES_CONFIG_FILE
    echo "# Author: Raffaello Bonghi" >> $MODULES_CONFIG_FILE
    echo "# Email: raffaello@rnext.it" >> $MODULES_CONFIG_FILE
    echo "" >> $MODULES_CONFIG_FILE
    
    # Add remote information
    if [ ! -z $MODULE_REMOTE_USER ] || [ ! -z $MODULE_REMOTE_HOST ]; then
        echo "# Remote information" >> $MODULES_CONFIG_FILE
        echo "MODULE_REMOTE_USER=\"$MODULE_REMOTE_USER\"" >> $MODULES_CONFIG_FILE
        echo "MODULE_PASSWORD=\"$MODULE_PASSWORD\"" >> $MODULES_CONFIG_FILE
        echo "MODULE_REMOTE_HOST=\"$MODULE_REMOTE_HOST\"" >> $MODULES_CONFIG_FILE
        echo "" >> $MODULES_CONFIG_FILE
    fi
    
    echo "# List of availables modules" >> $MODULES_CONFIG_FILE
    echo "MODULES_LIST=\"$MODULES_LIST\"" >> $MODULES_CONFIG_FILE
    
    echo "" >> $MODULES_CONFIG_FILE
    echo "# ----------------------------- " >> $MODULES_CONFIG_FILE
    echo "# -     Modules variables     - " >> $MODULES_CONFIG_FILE
    echo "# ----------------------------- " >> $MODULES_CONFIG_FILE
    echo "" >> $MODULES_CONFIG_FILE
    for folder in $MODULES_FOLDER/* ; do
      if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE_NAME=$(echo $folder | cut -f2 -d "/")
        local FILE="$folder"/$FILE_NAME.sh
        if [ -f $FILE ] ; then
            # Unset save function
            unset -f script_save
            # Load source
            source "$FILE"
            # Check if exist the function
            if type script_save &>/dev/null
            then
                # Write name module
                echo "# Variables for: $MODULE_NAME" >> $MODULES_CONFIG_FILE
                # Save script
                script_save $MODULES_CONFIG_FILE
                # Add space
                echo "" >> $MODULES_CONFIG_FILE
            fi
        fi
      fi
    done
        
    # echo "Save in $MODULES_CONFIG_FILE"
}

modules_isInList()
{
    IFS=':' read -ra MODULE <<< "$MODULES_LIST"
    for mod in "${MODULE[@]}"; do
        if [ "$mod" == $1 ] ; then
            echo "1"
            return
        fi
    done
    # Otherwise return 0
    echo "0"
}

modules_add()
{
    # Check if the module is in list otherwise add the new module
    if [[ $MODULES_LIST != *"$1"* ]] ; then
        # Add new element
        # echo "Add new module $1"
        MODULES_LIST+=":$1"
        # Sort all modules
        modules_sort
    #else
    #    echo "Module $1 is already in list"
    fi
}

modules_remove()
{
    # Remove from list
    MODULES_LIST=$(echo $MODULES_LIST | sed -e "s/$1//g")
    # Sort all modules
    modules_sort
}

# Modules check sudo
# https://serverfault.com/questions/266039/temporarily-increasing-sudos-timeout-for-the-duration-of-an-install-script
modules_sudo_me_start()
{
    # write sudo me file
    touch $MODULES_SUDO_ME_FILE
    # Loop script
    while [ -f $MODULES_SUDO_ME_FILE ]; do
        #echo "checking $$ ...$(date)"
        sudo -v
        sleep 10
    done &
}

modules_sudo_me_stop()
{
    # finish sudo loop
    rm $MODULES_SUDO_ME_FILE
}

modules_run()
{
    # Load exesudo
    #source include/exesudo.sh
    
    if [ ! -z $MODULES_LIST ] ; then
    
        # Start sudo_me
        modules_sudo_me_start
    
        echo "Start install script..."
        IFS=':' read -ra MODULE <<< "$MODULES_LIST"
        for mod in "${MODULE[@]}"; do
            # Check if exist the same file with the name of the folder
            local FOLDER="$MODULES_FOLDER/$mod"
            local FILE="$FOLDER/$mod.sh"
            if [ -f $FILE ] ; then
                # Unset save function
                unset -f script_run
                unset MODULE_DEFAULT
                # Local folder
                local LOCAL_FOLDER=$(pwd)
                # Load source
                source "$FILE"
                # Add only all modules without MODULE_DEFAULT=-1
                if [ $MODULE_DEFAULT -ne -1 ] ; then
                    # Write name module
                    echo "Running module - $MODULE_NAME"
                    # Check if exist the function
                    if type script_run &>/dev/null
                    then
                        # Move to same folder
                        cd $FOLDER
                        # run script
                        # exesudo script_run
                        script_run $LOCAL_FOLDER
                    fi
                    # Restore previuous folder
                    cd $LOCAL_FOLDER
                fi
            fi
        done

        # Stop sudo_me 
        modules_sudo_me_stop

        echo "... Done"        

    else
        echo "No modules"
    fi
}

modules_require_reboot()
{
    if [ -f /var/run/reboot-required ] || [ ! -z ${MODULES_REQUIRE_REBOOT+x} ] ; then
        echo "1"
    else
        echo "0"
    fi
}


