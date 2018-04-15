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
    
# Update the NVIDIA Jetson Kernel
# Reference
# Thanks @jetsonhacks
# https://github.com/NVIDIA-Jetson/jetson-trashformers/wiki/Re-configuring-the-Jetson-TX2-Kernel
# http://www.jetsonhacks.com/2017/03/25/build-kernel-and-modules-nvidia-jetson-tx2/
# https://github.com/jetsonhacks/buildJetsonTX2Kernel

MODULE_NAME="Update the NVIDIA Jetson Kernel"
MODULE_DESCRIPTION="This module update the NVIDIA Jetson and add new features:
FTDI driver converter
ACM driver"
MODULE_DEFAULT=0

kernel_has_removed()
{
    if [ $KERNEL_REMOVE_FOLDER == "YES" ] ; then 
        echo "X"
    else
        echo " "
    fi 
}

if [ -z ${KERNEL_REMOVE_FOLDER+x} ] ; then
    MODULE_SUBMENU=("Set folder kernel:set_path" "Add kernel patchs:set_kernel_patch" "[ ] Remove install after patching:kernel_is_removed")
else
    MODULE_SUBMENU=("Set folder kernel:set_path" "Add kernel patchs:set_kernel_patch" "[$(kernel_has_removed)] Remove install after patching:kernel_is_removed")
fi

##################################################################

KERNEL_SRC_CONFIG="/proc/config.gz"
KERNEL_SRC_FOLDER="/usr/src"
KERNEL_CONFIG_FILE=".config"

# Kernel driver list to check and add
KERNEL_DRIVER_LIST=("FTDI:CONFIG_USB_SERIAL_FTDI_SIO:Driver for FTDI converter" "ACM:CONFIG_USB_ACM:Driver for ACM peripherals")

##################################################################

kernel_extract_config()
{
    local config_file=$1
    # Extract config file in tmp if doesn't exist
    if [ ! -f $config_file ] ; then
        zcat $KERNEL_SRC_CONFIG > $config_file
    fi
}

kernel_is_enabled()
{
    if [[ $KERNEL_PATCH_LIST = *"$1"* ]] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

kernel_check_isconfig()
{
    local PARAMETER=$1 # Example CONFIG_USB_ACM
    local PARAMATER_STATUS="$2"
    local FILE=$3
    
    if [ $(grep -F "$PARAMETER" $FILE) == "$PARAMETER=$PARAMATER_STATUS" ] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

# Return the configuration name
kernel_get_config()
{
    for sub_element in "${KERNEL_DRIVER_LIST[@]}"
    do
        local name=$(echo $sub_element | cut -f1 -d ":")
        local config=$(echo $sub_element | cut -f2 -d ":")
        local description=$(echo $sub_element | cut -f3 -d ":")
        # Check if the name is equal
        if [ $name == $1 ] ; then
            echo "$config"
            return        
        fi
    done
}

# Print configuration driver on NVIDIA Jetson
script_list()
{
    # Show list only if exist the file
    if [ -f $KERNEL_SRC_CONFIG ] ; then
        local config_file="/tmp/config"
        # Extract config file in tmp if doesn't exist
        kernel_extract_config $config_file
        
        echo "(*) Installed drivers:"
        
        local sub_element
        for sub_element in "${KERNEL_DRIVER_LIST[@]}"
        do
            local name=$(echo $sub_element | cut -f1 -d ":")
            local config=$(echo $sub_element | cut -f2 -d ":")
            local description=$(echo $sub_element | cut -f3 -d ":")
            
            if [ $(kernel_check_isconfig $config "y" $config_file) == "ON" ] ; then
                echo "    - [X] $name - $description"
            else
                echo "    - [ ] $name - $description"
            fi
        done
    else
        echo "(*) $KERNEL_SRC_CONFIG doesn't exist"
    fi
}

kernel_installer_list()
{
    local config_file="/tmp/config"
    # Extract config file in tmp if doesn't exist
    kernel_extract_config $config_file

    local NEW_LIST=""
    
    local LIST
    IFS=' ' read -a LIST <<< "$KERNEL_PATCH_LIST"
    for name in "${LIST[@]}"
    do
        # Get config name
        local config=$(kernel_get_config $name)
        # Check if is not in kernel config
        if [ $(kernel_check_isconfig $config "y" $config_file) == "OFF" ] ; then
            NEW_LIST+="$name "
        fi
    done
    # Return the new list
    echo $NEW_LIST
}

# Installer script
script_run()
{
    # List of kernel link
    local KERNEL_LINK=""
    local KERNEL_INTERNAL_FOLDER=""
    local KERNEL_FOLDER=""
    if [ $JETSON_L4T == "28.2" ] ; then
        KERNEL_LINK="http://developer.download.nvidia.com/embedded/L4T/r28_Release_v2.0/BSP/source_release.tbz2"
        KERNEL_INTERNAL_FOLDER="public_release/kernel_src.tbz2"
        KERNEL_FOLDER="kernel/kernel-4.4"
    elif [ $JETSON_L4T == "28.1" ] ; then
        KERNEL_LINK="http://developer.download.nvidia.com/embedded/L4T/r28_Release_v1.0/BSP/source_release.tbz2"
        KERNEL_INTERNAL_FOLDER="sources/kernel_src-$(echo "${JETSON_BOARD,,}").tbz2"
        KERNEL_FOLDER="kernel/kernel-4.4"
    elif [ $JETSON_L4T == "27.1" ] ; then
        KERNEL_LINK="http://developer.download.nvidia.com/embedded/L4T/r27_Release_v1.0/BSP/r27.1.0_sources.tbz2"
        KERNEL_INTERNAL_FOLDER="kernel_src.tbz2"
        KERNEL_FOLDER="kernel/kernel-4.4"
    fi
    
    # List of driver to install
    local NEW_LIST=$(kernel_installer_list)
        
    # Check if is selected the right link version
    if [ ! -z $KERNEL_LINK ] ; then
    
        # Load installer functions
        source kernel_installer.sh
            
        if [ ! -z $NEW_LIST ] ; then
        
            tput setaf 6
            echo "Update the NVIDIA Jetson Kernel $(uname -r)"
            tput sgr0
            
            # Get sources
            kernel_get_sources $KERNEL_LINK $KERNEL_INTERNAL_FOLDER $KERNEL_FOLDER
            
            if [ $KERNEL_REMOVE_FOLDER == "YES" ] ; then
                if ! kernel_has_sources ; then
                    tput setaf 1
                    echo "Removing folder $KERNEL_SRC_FOLDER/$(kernel_has_sources_name)"
                    tput sgr0
                    sudo rm -R $KERNEL_SRC_FOLDER/$(kernel_has_sources_name)
                else
                    tput setaf 3
                    echo "The folder $KERNEL_SRC_FOLDER/$(kernel_has_sources_name) is already removed "
                    tput sgr0
                fi
            fi
            
            # Edit kernel
            kernel_edit $KERNEL_FOLDER $NEW_LIST
            # Make kernel
            kernel_make $KERNEL_FOLDER
            
            # Check if Image is generated
            if [ -f $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/arch/arm64/boot/Image ] ; then
            
                # Copy kernel
                kernel_copy_images $KERNEL_FOLDER
            
                if [ -d $KERNEL_SRC_FOLDER/$KERNEL_FOLDER ] ; then
                    tput setaf 6
                    echo "Removing folder $KERNEL_SRC_FOLDER/$KERNEL_FOLDER"
                    tput sgr0
                    sudo rm -R $KERNEL_SRC_FOLDER/$KERNEL_FOLDER
                else
                    tput setaf 3
                    echo "Source kernel folder $KERNEL_SRC_FOLDER/$KERNEL_FOLDER has removed!"
                    tput sgr0
                fi
            else
                tput setaf 1
                echo "Image is not built! Check Error in Kernel make!"
                tput sgr0
            fi
        else
            tput setaf 3
            echo "You don't have any driver to fix"
            tput sgr0
        fi
        
    else
        tput setaf 1
        echo "This driver kernel update is not available for your L4T $JETSON_L4T!"
        tput sgr0
    fi

}

check_drivers_installed()
{
    local config_file="/tmp/config"
    # Extract config file in tmp if doesn't exist
    kernel_extract_config $config_file
    
    KERNEL_CHECK_RADIO=()
    local sub_element
    for sub_element in "${KERNEL_DRIVER_LIST[@]}"
    do
        local name=$(echo $sub_element | cut -f1 -d ":")
        local config=$(echo $sub_element | cut -f2 -d ":")
        local description=$(echo $sub_element | cut -f3 -d ":")
        
        local status="OFF"
        if [ $(kernel_is_enabled $name) == "ON" ] || [ $(kernel_check_isconfig $config "y" $config_file) == "ON" ] ; then
            status="ON"
        else
            status="OFF"
        fi
        
        KERNEL_CHECK_RADIO+=($name "$description" $status)
    done
}

set_kernel_patch()
{
    # Run check list
    check_drivers_installed
    # Length list drivers
    local LENGTH=${#KERNEL_DRIVER_LIST[@]}
    
    local KERNEL_PATCH_TMP
    KERNEL_PATCH_TMP=$(whiptail --title "$MODULE_NAME" --checklist "Which kernel patch do you want add?" 15 60 $LENGTH "${KERNEL_CHECK_RADIO[@]}" 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save list of new element to patch
        KERNEL_PATCH_LIST=$KERNEL_PATCH_TMP
    fi
}

script_load_default()
{
    if [ -z ${KERNEL_DOWNLOAD_FOLDER+x} ] ; then
        # Write hostname
        KERNEL_DOWNLOAD_FOLDER="/usr/src"
    fi
    
    if [ -z ${KERNEL_PATCH_LIST+x} ] ; then
        # Empty kernel patch list 
        KERNEL_PATCH_LIST=""
    fi
    
    if [ -z ${KERNEL_REMOVE_FOLDER+x} ] ; then
        # Default configuration, after install the kernel sources will be removed 
        KERNEL_REMOVE_FOLDER="YES"
    fi
}

script_save()
{
    if [ ! -z ${KERNEL_DOWNLOAD_FOLDER+x} ] ; then
        if [ $KERNEL_DOWNLOAD_FOLDER != "/usr/src" ]
        then
            echo "KERNEL_DOWNLOAD_FOLDER=\"$KERNEL_DOWNLOAD_FOLDER\"" >> $1
        fi
    fi
    
    if [ ! -z ${KERNEL_PATCH_LIST+x} ] ; then
        if [ ! -z $KERNEL_PATCH_LIST ]
        then
            echo "KERNEL_PATCH_LIST=\"$KERNEL_PATCH_LIST\"" >> $1
        fi
    fi
    
    if [ ! -z ${KERNEL_REMOVE_FOLDER+x} ] ; then
        if [ $KERNEL_REMOVE_FOLDER != "YES" ]
        then
            echo "KERNEL_REMOVE_FOLDER=\"$KERNEL_REMOVE_FOLDER\"" >> $1
        fi
    fi
}

script_info()
{
    echo " - Download KERNEL sources in $KERNEL_DOWNLOAD_FOLDER"
    echo " - Will be patch with: $KERNEL_PATCH_LIST"
    if [ $KERNEL_REMOVE_FOLDER != "yes" ] ; then
        echo " - The kernel sources is saved in $KERNEL_DOWNLOAD_FOLDER/$KERNEL_FOLDER"
    else
        echo " - After install will be removed the $KERNEL_FOLDER from sources $KERNEL_DOWNLOAD_FOLDER"
    fi
}

kernel_remove_check()
{
    if [ $1 == $2 ] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

kernel_is_removed()
{
    local KERNEL_REMOVE_FOLDER_TMP_VALUE
    KERNEL_REMOVE_FOLDER_TMP_VALUE=$(whiptail --title "$MODULE_NAME" --radiolist \
    "Do you want remove sources after install?" 15 60 2 \
    "YES" "The folder will be removed" $(kernel_remove_check "YES" $KERNEL_REMOVE_FOLDER) \
    "NO" "The folder is not removed" $(kernel_remove_check "NO" $KERNEL_REMOVE_FOLDER) 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        KERNEL_REMOVE_FOLDER=$KERNEL_REMOVE_FOLDER_TMP_VALUE
    fi
    
}

set_path()
{
    if [ -z ${KERNEL_DOWNLOAD_FOLDER+x} ]
    then
        # Write hostname
        KERNEL_DOWNLOAD_FOLDER="/usr/src"
    fi
    
    local KERNEL_DOWNLOAD_FOLDER_TMP
    KERNEL_DOWNLOAD_FOLDER_TMP=$(whiptail --inputbox "Set the kernel path folder" 8 78 $KERNEL_DOWNLOAD_FOLDER --title "Kernel path" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the kernel download folder
        KERNEL_DOWNLOAD_FOLDER=$KERNEL_DOWNLOAD_FOLDER_TMP
    fi
}
