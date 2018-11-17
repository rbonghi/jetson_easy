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
MODULES_CONFIG_FOLDER="config"
# Absolute path configuration file
MODULES_CONFIG_PROJECT=""
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


# MODULES_DEFAULT options:
# - DIS  - Disable module
# - STOP - NO Install
# - RUN  - Default install
# - AUTO - Automatic mode
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
                unset MODULE_DEFAULT
                # Load source
                source "$FILE"
                # If MODULE_DEFAULT doesn't exist set automatically stop
                if [ -z ${MODULE_DEFAULT+x} ] ; then
                    $MODULE_DEFAULT = "STOP"
                fi
                # Add in list all modules with default option
                if [ $MODULE_DEFAULT != "DIS" ] ; then
                    MODULES_LIST+="$FILE_NAME|$MODULE_DEFAULT:"
                fi
                # Check if exist the function
                if type script_load_default &>/dev/null ; then
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
	local MODULES_CONFIG=$MODULES_CONFIG_FOLDER/$MODULES_CONFIG_NAME
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
		# If is a directory check if exist file MODULES_CONFIG_NAME (standard name is: config/setup.txt)
		local setup_file=$config_path/$MODULES_CONFIG_NAME
		# Check if exist config file
		if [[ -f $setup_file ]]; then
			# echo "$setup_file is a jetson easy folder"
			# Set variables
			MODULES_CONFIG_PATH=$(realpath $config_path)
			MODULES_CONFIG_FILE=$(realpath $setup_file)
			MODULES_CONFIG_PROJECT=$(basename $MODULES_CONFIG_PATH)
			return 0
		#else
			#echo "$setup_file is not a jetson easy folder"
		fi
	elif [[ -f $config_path ]]; then
		#echo "$config_path is a jetson easy file"
		# Set variables
		MODULES_CONFIG_PATH=$(realpath $USER_PWD)
		MODULES_CONFIG_FILE=$(realpath $config_path)
		MODULES_CONFIG_PROJECT=$(basename $MODULES_CONFIG_PATH)
		return 0
	#else
		#echo "$config_path is not valid"
	fi
	# Set default configuration
	MODULES_CONFIG_PATH="$USER_PWD/$MODULES_CONFIG_FOLDER"
	MODULES_CONFIG_FILE="$MODULES_CONFIG_PATH/$MODULES_CONFIG_NAME"
	MODULES_CONFIG_PROJECT=$(basename $MODULES_CONFIG_PATH)
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
    local mod
    for mod in "${MODULE[@]}"; do
        # Take name
        local name=$(echo $mod | cut -d "|" -f 1)
        # Check if the name is the same
        if [ $name == $1 ] ; then
            # Return the mode
            echo $(echo $mod | cut -d "|" -f 2)
            return 0
        fi
    done
    # Otherwise return 0
    echo "STOP"
}

modules_update()
{
    IFS=':' read -ra MODULE <<< "$MODULES_LIST"
    local new_list
    local mod
    local check=0
    for mod in "${MODULE[@]}"; do
        # Take name
        local name=$(echo $mod | cut -d "|" -f 1)
        # Check if the name is the same
        if [ $name == $1 ] ; then
            new_list+=":$1|$2"
            check=1
        else
            # Add same module in the list
            new_list+=":$mod"
        fi
    done
    # If this module is not in list add in tail
    if [ $check == 0 ] ; then
        new_list+=":$1|$2"
    fi
    #Update MODULES_LIST
    MODULES_LIST=$new_list
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

modules_run_script()
{
    # Check if exist the function
    if type script_run &>/dev/null ; then
        # Move to same folder
        cd $FOLDER
        # run script
        # exesudo script_run
        script_run $LOCAL_FOLDER
        # Restore previuous folder
        cd $LOCAL_FOLDER
    fi
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
            # Take name and option
            local name=$(echo $mod | cut -d "|" -f 1)
            local option=$(echo $mod | cut -d "|" -f 2)
            # Check if exist the same file with the name of the folder
            local FOLDER="$MODULES_FOLDER/$name"
            local FILE="$FOLDER/$name.sh"
            # Overload name FOLDER and file if the name is the same of project
            if [ $name == "X-$MODULES_CONFIG_PROJECT" ] ; then
                FOLDER="$MODULES_CONFIG_PATH"
                FILE="$FOLDER/X-$MODULES_CONFIG_PROJECT.sh"
            fi
            if [ -f $FILE ] ; then
                # Unset save function
                unset -f script_run
                unset -f script_check
                unset MODULE_DEFAULT
                # Local folder
                local LOCAL_FOLDER=$(pwd)
                case $option in
                    "AUTO")  # Load source
                        source "$FILE"
                        echo "Running module - $MODULE_NAME in mode AUTO mode"
                        # Check if exist the function
                        if type script_check &>/dev/null ; then
							# Move to same folder
							cd $FOLDER
                            # Run script check function
                            script_check $LOCAL_FOLDER
                            local RET=$?
							# Restore previuous folder
							cd $LOCAL_FOLDER
                            if [ $RET == 1 ] ; then
                                # run Script
                                modules_run_script
                            else
                                echo "Not require other updates"
                            fi
                        else
                            echo "Any check function are installed, please check module $MODULE_NAME"
                        fi ;;
                    "RUN")  # Load source
                        source "$FILE"
                        echo "Running module - $MODULE_NAME"
                        # run Script
                        modules_run_script ;;
                    *) ;;
                esac
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


