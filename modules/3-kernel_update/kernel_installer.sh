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

kernel_has_sources()
{
    local kernel_dir="$(dirname $KERNEL_INTERNAL_FOLDER)"
    if [ $kernel_dir == "." ] ; then
        if [ ! -f $KERNEL_INTERNAL_FOLDER ] ; then
            true
        else
            false
        fi
    else
        if [ ! -d $kernel_dir ] ; then
            true
        else
            false
        fi
    fi
}

kernel_has_sources_name()
{
    local kernel_dir="$(dirname $KERNEL_INTERNAL_FOLDER)"
    if [ $kernel_dir == "." ] ; then
        echo $KERNEL_INTERNAL_FOLDER
    else
        echo $kernel_dir
    fi
}

kernel_get_sources()
{
    # List of kernel link
    local KERNEL_LINK=$1
    local KERNEL_INTERNAL_FOLDER=$2
    local KERNEL_FOLDER=$3

    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    tput setaf 6
    echo "Move in download folder: $KERNEL_SRC_FOLDER"
    tput sgr0
    # Move in jetson folder
    cd $KERNEL_SRC_FOLDER

    #echo "Download $KERNEL_LINK - in $KERNEL_DOWNLOAD_FOLDER"
    echo "Extract $KERNEL_INTERNAL_FOLDER"
    echo "Kernel folder $KERNEL_FOLDER"

    # Install pkg-config
    sudo apt-get install pkg-config -y
    
    # Check if the folder Kernel folder exist
    if kernel_has_sources ; then

        # Variable kernel file
        local DOWNLOAD_NAME_FILE="$KERNEL_DOWNLOAD_FOLDER/source_release.tbz2"
    
        # Download kernel
        if [ ! -f $DOWNLOAD_NAME_FILE ] ; then
            tput setaf 6
            echo "Download source kernel $JETSON_L4T"
            tput sgr0
            sudo wget --output-document $DOWNLOAD_NAME_FILE $KERNEL_LINK
        else
            tput setaf 3
            echo "The source file has is $DOWNLOAD_NAME_FILE"
            tput sgr0
        fi
        
        # Extracting sources
        if kernel_has_sources ; then
            tput setaf 6
            echo "Extracting $DOWNLOAD_NAME_FILE from $KERNEL_INTERNAL_FOLDER source"
            tput sgr0
            sudo tar -xvf $DOWNLOAD_NAME_FILE $KERNEL_INTERNAL_FOLDER
        else
            tput setaf 3
            echo "The source kernel has is $KERNEL_INTERNAL_FOLDER"
            tput sgr0
        fi
        
        # Remove source
        if [ -f $DOWNLOAD_NAME_FILE ] ; then
            tput setaf 6
            echo "Removing download file $DOWNLOAD_NAME_FILE"
            tput sgr0
            sudo rm $DOWNLOAD_NAME_FILE
        else
            tput setaf 3
            echo "Downloaded $DOWNLOAD_NAME_FILE file already removed!"
            tput sgr0
        fi
    else
        tput setaf 3
        echo "Source folder has available"
        tput sgr0
    fi
    
    tput setaf 6
    echo "Expanding $KERNEL_INTERNAL_FOLDER in $KERNEL_SRC_FOLDER/$KERNEL_INTERNAL_FOLDER"
    tput sgr0
    sudo tar -xf $KERNEL_INTERNAL_FOLDER
    
    tput setaf 6
    echo "Move in download folder: $KERNEL_SRC_FOLDER/$KERNEL_FOLDER"
    tput sgr0
    cd $KERNEL_FOLDER
    
    if [ ! -f $KERNEL_CONFIG_FILE ]; then
        tput setaf 6
        echo "Copy config folder $KERNEL_SRC_CONFIG in $KERNEL_CONFIG_FILE"
        tput sgr0
        sudo zcat $KERNEL_SRC_CONFIG > $KERNEL_CONFIG_FILE
    else
        tput setaf 3
        echo "Config file $KERNEL_CONFIG_FILE from $KERNEL_SRC_CONFIG has copied before!"
        tput sgr0
    fi
    
    # Ready to configure kernel
    #make xconfig
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

kernel_edit()
{
    local KERNEL_FOLDER=$1
    shift 1
    local KERNEL_ADD=$@
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    tput setaf 6
    echo "List driver to add: $KERNEL_ADD"
    tput sgr0
    
    
    tput setaf 6
    echo "Move in download folder: $KERNEL_SRC_FOLDER/$KERNEL_FOLDER"
    tput sgr0
    # Move to the kernel folder
    cd $KERNEL_SRC_FOLDER/$KERNEL_FOLDER
    
    local config_file=$KERNEL_SRC_FOLDER/$KERNEL_FOLDER/$KERNEL_CONFIG_FILE

    local LIST
    IFS=' ' read -a LIST <<< "$KERNEL_ADD"
    for name in "${LIST[@]}"
    do
        local config=$(kernel_get_config $name)
        
        if [ $(kernel_check_isconfig $config "y" $config_file) == "OFF" ] ; then
            # Patch the config file
            tput setaf 4
            echo "Update kernel with $name driver"
            tput sgr0
            # Update kernel
            sudo sed -i "s/.*$config.*/$config=y/" $config_file
        else
            tput setaf 3
            echo "$name driver is already configured!"
            tput sgr0
        fi
    done
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

kernel_fix_makefile()
{
    local KERNEL_FOLDER=$1
    
    # Fix errors install
    # Thx from @jetsonhacks
    # https://github.com/jetsonhacks/buildJetsonTX1Kernel.git
    if [ $JETSON_L4T == "28.1" ] ; then
        tput setaf 1
        echo "Fix the Makefiles so that they compile on the device with kernel $JETSON_L4T"
        tput sgr0
        # Fix the Makefiles so that they compile on the device
        sudo patch $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/drivers/devfreq/Makefile ./diffs/devfreq/devfreq.patch
        sudo patch $KERNEL_SRC_FOLDER/kernel/nvgpu/drivers/gpu/nvgpu/Makefile ./diffs/nvgpu/nvgpu.patch
        
        # The Jetson TX2 requires the following; Not needed for the Jetson TX1
        if [ $JETSON_BOARD == "TX2" ] ; then
            sudo patch $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/sound/soc/tegra-alt/Makefile ./diffs/tegra-alt/tegra-alt.patch
        fi
        
        # vmipi is in a sub directory without a Makefile, there was an include problem
        sudo cp $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/drivers/media/platform/tegra/mipical/mipi_cal.h $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/drivers/media/platform/tegra/mipical/vmipi/mipi_cal.h
    
    # Fix CONFIG_TEGRA_THROUGHPUT in L4T 28.2
    elif [ $JETSON_L4T == "28.2" ] ; then
        tput setaf 1
        echo "Fix with \"CONFIG_TEGRA_THROUGHPUT=n\" in kernel $JETSON_L4T"
        tput sgr0
        echo "CONFIG_TEGRA_THROUGHPUT=n" >> $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/$KERNEL_CONFIG_FILE
    fi
}

kernel_make()
{
    local KERNEL_FOLDER=$1
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    local NUM_CPU=$(nproc)
    
    tput setaf 6
    echo "Make kernel with $NUM_CPU CPU"
    tput sgr0
    
    # Builds the kernel and modules
    # Assumes that the .config file is available
    cd $KERNEL_SRC_FOLDER/$KERNEL_FOLDER
    
    # Fix makefile errors
    kernel_fix_makefile $KERNEL_FOLDER
    
    sudo make prepare
    sudo make modules_prepare
    sudo make -j$NUM_CPU Image
    sudo make modules
    sudo make modules_install
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

kernel_copy_images()
{
    local KERNEL_FOLDER=$1
    
    if [ -f $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/arch/arm64/boot/Image ] ; then
        tput setaf 6
        echo "Copy image in /boot/Image"
        tput sgr0
        
        #sudo cp $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/arch/arm64/boot/zImage /boot/zImage
        sudo cp $KERNEL_SRC_FOLDER/$KERNEL_FOLDER/arch/arm64/boot/Image /boot/Image
        
        # Require reboot
        tput setaf 1
        echo "Require reboot"
        tput sgr0
        MODULES_REQUIRE_REBOOT=1
    else
        tput setaf 1
        echo "Image File doesn't exist!"
        tput sgr0
    fi
}
