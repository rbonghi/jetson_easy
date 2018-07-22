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

menu_config_select()
{
    if (whiptail --title "$(menu_title)Biddibi Boddibi Boo" --scrolltext --yesno "Configuration select: $1" 8 50 3>&1 1>&2 2>&3) then
        #Set config folder to select file/folder
        config_folder=$1
	    # Load configuration modules
	    modules_load_config $config_folder
        # Load all modules
        modules_load
    else
        menu_filebrowser $(dirname $1)
    fi
}

menu_filebrowser()
{
    local real_path=$(realpath $1)
    
    #Build the folder list
    local FILE_LIST=("../" "BACK")
    local folder
    for folder in $(ls --group-directories-first -p $real_path) ; do
        local description= "a"
        local status=$(find "$real_path/$folder" -maxdepth 1 -name "*.txt" 2>/dev/null)
        if [[ ! -z $status ]]; then
            description="config"
        fi
        FILE_LIST+=("$folder" "$description")
    done
    # Build the menu
    local PATH_SELECT
    PATH_SELECT=$(whiptail --title "$(menu_title)Biddibi Boddibi Boo" --menu "Select configuration in $real_path" 20 50 10 "${FILE_LIST[@]}" 3>&1 1>&2 2>&3)
    
    local RET=$?
    if [ $RET -eq 0 ]; then
        
        if [[ ! -z $(find "$real_path/$PATH_SELECT" -maxdepth 1 -name "*.txt") ]]; then
            # The folder contain the configuration folder
            #echo "path=$(realpath $real_path/$PATH_SELECT)"
            if [ "$real_path/$PATH_SELECT" != "$USER_PWD/" ]; then
                menu_config_select $real_path/$PATH_SELECT
            else
                menu_filebrowser $real_path/$PATH_SELECT
            fi
        elif [[ -f "$real_path/$PATH_SELECT" ]]; then
            #Check if the file selected if a .txt file
            local filename=$(basename -- "$real_path/$PATH_SELECT")
            local extension="${filename##*.}"
            if [ $extension == "txt" ]; then
                #echo "path=$(realpath $real_path/$PATH_SELECT)"
                menu_config_select $real_path/$PATH_SELECT
            else
                menu_filebrowser $real_path
            fi
        elif [[ -d "$real_path/$PATH_SELECT" ]]; then
            # Otherwise enter in other folder
            menu_filebrowser "$real_path/$PATH_SELECT"
        else
            menu_filebrowser
        fi
    fi
}

menu_message_introduction()
{
    if [ -e $USER_PWD/$MODULES_CONFIG_NAME ] || [ $config_folder != "$USER_PWD" ] ; then
        whiptail --title "$(menu_title)Biddibi Boddibi Boo" --textbox /dev/stdin 22 45 <<< "$(menu_header)
--------------------------------------
Load Config from $config_folder"
    else
        if (whiptail --title "$(menu_title)Biddibi Boddibi Boo" --scrolltext --yes-button "Load config" --no-button "skip" --yesno "$(menu_header)" 19 45 3>&1 1>&2 2>&3) then
            #echo "Config pressed"
            menu_filebrowser $USER_PWD
        fi
    fi
}

