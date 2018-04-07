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

KERNEL_SRC_FOLDER="/usr/src"
KERNEL_FOLDER="kernel/kernel-4.4"
KERNEL_CONFIG_FILE=".config"

kernel_is_enabled()
{
    if [[ $KERNEL_PATCH_LIST = *"$1"* ]] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

edit_kernel()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    # Move to the kernel folder
    cd $KERNEL_SRC_FOLDER/$KERNEL_FOLDER
    
    if [ $(kernel_is_enabled "FTDI") == "ON" ] ; then
        # Patch the config file
        tput setaf 6
        echo "Add in kernel FTDI driver"
        tput sgr0
        
    fi
    
    if [ $(kernel_is_enabled "ACM") == "ON" ] ; then
        tput setaf 6
        echo "Add in kernel ACM driver"
        tput sgr0
        # https://github.com/NVIDIA-Jetson/jetson-trashformers/wiki/Re-configuring-the-Jetson-TX2-Kernel
        sudo sed -i 's/.*CONFIG_USB_ACM.*/CONFIG_USB_ACM=y/' $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/$KERNEL_CONFIG_FILE
    fi
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

make_kernel()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)
        
    tput setaf 6
    echo "Make kernel"
    tput sgr0
    
    # Builds the kernel and modules
    # Assumes that the .config file is available
    cd $KERNEL_SRC_FOLDER/$KERNEL_FOLDER
    
    sudo make prepare
    sudo make modules_prepare
    sudo make -j6
    sudo make modules
    sudo make modules_install
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

copy_images()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    tput setaf 6
    echo "Copy image in /boot/Image"
    tput sgr0
    
    cd $KERNEL_SRC_FOLDER/$KERNEL_FOLDER
    
    #sudo cp arch/arm64/boot/zImage /boot/zImage
    sudo cp arch/arm64/boot/Image /boot/Image
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
    
    # Require reboot
    tput setaf 1
    echo "Require reboot"
    tput sgr0
    MODULES_REQUIRE_REBOOT=1
}

get_kernel_sources()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)

    # List of kernel link
    local KERNEL_LINK=""
    local KERNEL_INTERNAL_FOLDER=""
    if [ $JETSON_L4T == "28.2" ] ; then
        KERNEL_LINK="http://developer.download.nvidia.com/embedded/L4T/r28_Release_v2.0/BSP/source_release.tbz2"
        KERNEL_INTERNAL_FOLDER="public_release/kernel_src.tbz2"
    elif [ $JETSON_L4T == "28.1" ] ; then
        KERNEL_LINK="http://developer.download.nvidia.com/embedded/L4T/r28_Release_v1.0/BSP/source_release.tbz2"
        KERNEL_INTERNAL_FOLDER="sources/kernel_src-$(echo "${JETSON_BOARD,,}").tbz2"
    elif [ $JETSON_L4T == "27.1" ] ; then
        KERNEL_LINK="http://developer.download.nvidia.com/embedded/L4T/r27_Release_v1.0/BSP/r27.1.0_sources.tbz2"
        KERNEL_INTERNAL_FOLDER="kernel_src.tbz2"
    fi

    # Install pkg-config
    sudo apt-get install pkg-config -y
    
    tput setaf 6
    echo "Move in download folder: $KERNEL_SRC_FOLDER"
    tput sgr0
    # Move in jetson folder
    cd $KERNEL_SRC_FOLDER
    
    # Check if the folder Kernel folder exist
    if [ ! -d "$KERNEL_FOLDER" ]; then
    
        # Variable kernel file
        local KERNEL_FILE="source_release.tbz2"
    
        if [ ! -f $KERNEL_FILE ]; then
            # Download kernel
            tput setaf 6
            echo "Download source kernel $JETSON_L4T"
            tput sgr0
            sudo wget --output-document $KERNEL_DOWNLOAD_FOLDER/$KERNEL_FILE $KERNEL_LINK
        fi
        
        if [ ! -f $KERNEL_INTERNAL_FOLDER ]; then
            tput setaf 6
            echo "Extracting $KERNEL_FILE from $KERNEL_INTERNAL_FOLDER source"
            tput sgr0
            sudo tar -xvf $KERNEL_DOWNLOAD_FOLDER/$KERNEL_FILE $KERNEL_INTERNAL_FOLDER
        fi
        
        tput setaf 6
        echo "Expanding $KERNEL_INTERNAL_FOLDER"
        tput sgr0
        sudo tar -xf $KERNEL_INTERNAL_FOLDER
        
        local kernel_dir="$(dirname $KERNEL_INTERNAL_FOLDER)"
        if [ $kernel_dir == "." ] ; then
            echo "no folder"
        else
            echo "Remove folder $kernel_dir"
            sudo rm -r $kernel_dir
        fi
        
        # Remove source file
        if [ -f $KERNEL_FILE ]; then
            tput setaf 6
            echo "Remove $KERNEL_DOWNLOAD_FOLDER/$KERNEL_FILE kernel source"
            tput sgr0
            sudo rm -r $KERNEL_DOWNLOAD_FOLDER/$KERNEL_FILE
        fi
    fi
    
    cd $KERNEL_FOLDER
    if [ ! -f $KERNEL_CONFIG_FILE ]; then
        tput setaf 6
        echo "Copy config folder /proc/config.gz in $KERNEL_CONFIG_FILE"
        tput sgr0
        sudo zcat /proc/config.gz > $KERNEL_CONFIG_FILE
    fi
    # Ready to configure kernel
    #make xconfig
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

script_run()
{   
    tput setaf 6
    echo "Update the NVIDIA Jetson Kernel $(uname -r)"
    tput sgr0
    
    if [ $JETSON_L4T == "27.1" ] || [ $JETSON_L4T == "28.1" ] || [ $JETSON_L4T == "28.2" ] ; then
        # Run get kernel sources
        get_kernel_sources 
        
        # Edit, make and copy only if the list is not empty    
        if [ "$KERNEL_PATCH_LIST" != "" ] ; then
            echo "Patch kernel and add: $KERNEL_PATCH_LIST"
            # Patch the kernel
            edit_kernel
            
            # Make the kernel
            make_kernel
            
            # Copy images
            copy_images
        else
            tput setaf 1
            echo "No patch in list!"
            tput sgr0
        fi
        
        if [ $KERNEL_REMOVE_FOLDER == "YES" ] ; then
            tput setaf 1
            echo "Removing folder $KERNEL_SRC_FOLDER/$KERNEL_FOLDER"
            tput sgr0
            sudo rm -R $KERNEL_SRC_FOLDER/$KERNEL_FOLDER
        fi
        
    else
        tput setaf 1
        echo "This kernel updater doesn't work with this Jetpack $JETSON_JETPACK [L4T $JETSON_L4T]"
        tput sgr0
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
        KERNEL_PATCH_LIST="\"\""
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
        if [ $KERNEL_PATCH_LIST != "" ]
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

set_kernel_patch()
{
    if [ -z ${KERNEL_PATCH_LIST+x} ]
    then
        # Empty kernel patch list
        KERNEL_PATCH_LIST=""
    fi
    
    local KERNEL_PATCH_TMP
    KERNEL_PATCH_TMP=$(whiptail --title "$MODULE_NAME" --checklist \
    "Which kernel patch do you want add?" 15 60 2 \
    "FTDI" "Enable FTDI driver" $(kernel_is_enabled "FTDI") \
    "ACM" "Enable ACM driver" $(kernel_is_enabled "ACM") 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save list of new element to patch
        KERNEL_PATCH_LIST="$KERNEL_PATCH_TMP"
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

