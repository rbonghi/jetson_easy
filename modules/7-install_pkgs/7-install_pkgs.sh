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
MODULE_DEFAULT=0

MODULE_SUBMENU=("Add new packages:set_pkgs")

pkgs_is_enabled()
{
    if [[ $PKGS_PATCH_LIST = *"$1"* ]] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

# Reference
# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
vercomp()
{
    if [[ $1 == $2 ]]
    then
        echo "0"
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0vercomp
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            echo "1"
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo "2"
            return 2
        fi
    done
    echo "0"
    return 0
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
    
    if [ $(pkgs_is_enabled "ZED") == "ON" ] ; then
    
        local ZED_VERSION="2.3"
    
        # Check if is installed CUDA
        if [ ! -z ${JETSON_CUDA+x} ] ; then
            tput setaf 6
            echo "Install ZED driver on $JETSON_DESCRIPTION [L4T $JETSON_L4T] with CUDA $JETSON_CUDA"
            tput sgr0
            local JETSON_NAME
            # Select version board
            if [ $JETSON_BOARD == "TX1" ] ; then
                JETSON_NAME="tegrax1"
            elif [ $JETSON_BOARD == "TX2" ] || [ $JETSON_BOARD == "TX2i" ] ; then
                JETSON_NAME="tegrax2"
                
                # Check which release of cuda has installed
                if [ $(vercomp $JETSON_CUDA "9") = "0" ] ; then
                    JETSON_NAME+="_jp32"
                elif [ $(vercomp $JETSON_CUDA "8") = "0" ] ; then
                    JETSON_NAME+="_jp31"
                fi
            fi
            
            tput setaf 6
            echo "Download https://download.stereolabs.com/zedsdk/$ZED_VERSION/$JETSON_NAME"
            tput sgr0
            
            # TODO check how to install silent the ZED sdk
            # wget https://download.stereolabs.com/zedsdk/$ZED_VERSION/$JETSON_NAME
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
        echo "Saved packages list"
    fi
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
    "Which new packages do you want add?" 15 60 3 \
    "nano" "It is an easy-to-use text editor" $(pkgs_is_enabled "nano") \
    "htop" "Interactive processes viewer" $(pkgs_is_enabled "htop") \
    "ZED" "Install ZED driver" $(pkgs_is_enabled "ZED") 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save list of new element to patch
        PKGS_PATCH_LIST="$PKGS_PATCH_LIST_TMP"
    fi
    
}
