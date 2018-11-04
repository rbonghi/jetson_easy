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

# Install standard packages

MODULE_NAME="Install standard packages"
MODULE_DESCRIPTION="Install standard packages:
htop
nano"
MODULE_DEFAULT="STOP"
MODULE_OPTIONS=("RUN" "STOP")

MODULE_SUBMENU=("Add new packages:set_pkgs")

INSTALL_ZED_VERSION="2.7"

pkgs_is_enabled()
{
    if [[ $PKGS_PATCH_LIST = *"$1"* ]] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

script_run()
{
    echo "Install standard packages"
    
    if [ $(pkgs_is_enabled "htop") == "ON" ] ; then
        tput setaf 6
        echo "Install htop"
        tput sgr0
        sudo apt-get install htop -y
    fi
    
    if [ $(pkgs_is_enabled "nano") == "ON" ] ; then
        tput setaf 6
        echo "Install nano"
        tput sgr0
        sudo apt-get install nano -y
    fi

    if [ $(pkgs_is_enabled "iftop") == "ON" ] ; then
        tput setaf 6
        echo "Install iftop"
        tput sgr0
        sudo apt-get install iftop -y
    fi
    
    if [ $(pkgs_is_enabled "ZED") == "ON" ] ; then
    
        # Check if is installed CUDA
        if [ ! -z ${JETSON_CUDA+x} ] ; then
            tput setaf 6
            echo "Install ZED driver on $JETSON_DESCRIPTION [L4T $JETSON_L4T] with CUDA $JETSON_CUDA"
            tput sgr0
            local JETSON_NAME
            # Select version board
            if [ $JETSON_BOARD == "Xavier" ] ; then
                 JETSON_NAME="tegraxavier"
            elif [ $JETSON_BOARD == "TX1" ] ; then
                JETSON_NAME="tegrax1"
            elif [ $JETSON_BOARD == "TX2" ] || [ $JETSON_BOARD == "TX2i" ] ; then
                JETSON_NAME="tegrax2"
                if [ $INSTALL_ZED_VERSION = "2.3" ] ; then
                    # Check which release of cuda has installed
                    if [ $(jetson_vercomp $JETSON_CUDA "9") -ge "0" ] ; then
                        JETSON_NAME+="_jp32"
                    elif [ $(jetson_vercomp $JETSON_CUDA "8") -ge "0" ] ; then
                        JETSON_NAME+="_jp31"
                    fi
                fi
            fi
            
            # Example output
            # https://download.stereolabs.com/zedsdk/2.7/tegraxavier

            tput setaf 6
            echo "Download https://download.stereolabs.com/zedsdk/$INSTALL_ZED_VERSION/$JETSON_NAME"
            tput sgr0
            
            # Local folder
            local LOCAL_FOLDER=$(pwd)
            # Move in temporary folder
            cd /tmp
            
            # Download ZED drivers
            wget --output-document zed_driver.run https://download.stereolabs.com/zedsdk/$INSTALL_ZED_VERSION/$JETSON_NAME
            
            # Set executable launcher
            chmod +x zed_driver.run
            
            # Launch zed_driver in silent mode
            ./zed_driver.run --quiet -- "silent"
            
            # Remove zed driver
            rm zed_driver.run
            
            # Restore previuous folder
            cd $LOCAL_FOLDER
        else
            tput setaf 1
            echo "I can't install the ZED drivers CUDA is not installed!"
            tput sgr0
        fi
    fi
}

script_load_default()
{
    if [ -z ${PKGS_PATCH_LIST+x} ] ; then
        # Empty packages patch list 
        PKGS_PATCH_LIST="\"\""
    fi
}

script_save()
{    
    if [ ! -z ${PKGS_PATCH_LIST+x} ] ; then
        if [ $PKGS_PATCH_LIST != "\"\"" ]
        then
            echo "PKGS_PATCH_LIST=\"$PKGS_PATCH_LIST\"" >> $1
        fi
    fi
}

script_info()
{
    echo " - Will be add this packages: $PKGS_PATCH_LIST"
}

set_pkgs()
{
    if [ -z ${PKGS_PATCH_LIST+x} ]
    then
        # Empty kernel patch list
        PKGS_PATCH_LIST="\"\""
    fi
    
    local PKGS_PATCH_LIST_TMP
    PKGS_PATCH_LIST_TMP=$(whiptail --title "$MODULE_NAME" --checklist \
    "Which new packages do you want add?" 15 60 4 \
    "nano" "It is an easy-to-use text editor" $(pkgs_is_enabled "nano") \
    "htop" "Interactive processes viewer" $(pkgs_is_enabled "htop") \
    "iftop" "Network traffic viewer" $(pkgs_is_enabled "iftop") \
    "ZED" "Install ZED driver version:$INSTALL_ZED_VERSION" $(pkgs_is_enabled "ZED") 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save list of new element to patch
        PKGS_PATCH_LIST="$PKGS_PATCH_LIST_TMP"
    fi
    
}
