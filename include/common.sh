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

##########################################

# Reference
# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
jetson_vercomp()
{
    if [[ $1 == $2 ]]
    then
        echo "0"
        return
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # Check if the versions are number
    re='^[0-9]+$'
    if ! [[ $ver1 =~ $re ]] ; then
       #echo "$ver1 error: Not a number" >&2
       echo "NaN"
       return
    fi
    if ! [[ $ver2 =~ $re ]] ; then
       #echo "$ver2 error: Not a number" >&2
       echo "NaN"
       return
    fi
    
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
            return
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo "-1"
            return
        fi
    done
    echo "0"
    return
}

####################################

menu_title()
{
    if [ ! -z ${DEBUG+x} ]
    then
        echo "DEBUG MODE - "
    else
        echo ""
    fi
}

menu_header()
{
    echo "NVIDIA Jetson Easy setup script"
    echo ""
    echo "An easy installer for your NVIDIA Jetson"
    echo ""
    echo "Author: Raffaello Bonghi"
    echo "email: raffaello@rnext.it"
    echo ""
    echo "--------------- LEGEND ---------------"
    echo "[up arrow | down arrow] = Move on page"
    echo "[tab | left arrow] = Go on buttons"
    echo "[space] = Select option"
    echo "[enter] = Save option"
    echo "[ESC] = Go back"
}

menu_info()
{
    echo "(*) System:"
    echo "    - User: $USER"
    if [ ! -z ${NEW_HOSTNAME+x} ]
    then
        if [ $NEW_HOSTNAME != $HOSTNAME ]
        then
            echo "    - Hostname: $HOSTNAME -> $NEW_HOSTNAME"
        else
            echo "    - Hostname: $HOSTNAME"         
        fi
    else
        echo "    - Hostname: $HOSTNAME"
    fi
    echo "    - OS: $DISTRIB_DESCRIPTION - $DISTRIB_CODENAME"
    echo "    - Architecture: $OS_ARCHITECTURE"
    echo "    - Kernel: $OS_KERNEL"
}

jetson_status()
{
    if [ ! -z ${JETSON_BOARD+x} ] ; then
        echo "(*) NVIDIA embedded:"
        echo "    - Board: $JETSON_DESCRIPTION"
        echo "    - Jetpack $JETSON_JETPACK [L4T $JETSON_L4T]"
        echo "    - CUDA: $JETSON_CUDA"
        echo "    - OpenCV: $JETSON_OPENCV"
    else
        echo "(*) It isn't an NVIDIA Jetson"
    fi
}

menu_message_introduction()
{
    whiptail --title "$(menu_title)Biddibi Boddibi Boo" --textbox /dev/stdin 19 45 <<< "$(menu_header)"
}

