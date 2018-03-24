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

# To Enable the debug mode
if [ -f DEBUG ]; then
    DEBUG=1
fi

# Load environment variables:
# - DISTRIB_ID
# - DISTRIB_RELEASE
# - DISTRIB_CODENAME
# - DISTRIB_DESCRIPTION
source /etc/lsb-release

# Load architecture
OS_ARCHITECTURE=$(uname -m)
OS_KERNEL=$(uname -r)

# Load environment variables:
# - JETSON_BOARD
# - JETSON_L4T (JETSON_L4T_RELEASE, JETSON_L4T_REVISION)
# - JETSON_DESCRIPTION
# - JETSON_CUDA
source jetson/jetson_variables.sh

menu_title()
{
    if [ ! -z ${DEBUG+x} ]
    then
        echo "DEBUG MODE - Biddibi Boddibi Boo"
    else
        echo "Biddibi Boddibi Boo"
    fi
}

menu_header()
{
    echo "NVIDIA Jetson Easy setup script"
    echo "Author: Raffaello Bonghi"
    echo " email: raffaello@rnext.it"
}

jetson_status()
{
    echo "NVIDIA embedded:"
    echo " - Board: $JETSON_DESCRIPTION"
    echo " - Jetpack $JETSON_JETPACK [L4T $JETSON_L4T]"
    echo " - CUDA: $JETSON_CUDA"
}

system_info()
{
    menu_header
    echo ""
    echo "User: $USER"
    echo "Hostname: $HOSTNAME"
    echo ""
    echo "System:"
    echo " - OS: $DISTRIB_DESCRIPTION - $DISTRIB_CODENAME"
    echo " - Architecture: $OS_ARCHITECTURE"
    echo " - Kernel: $OS_KERNEL"
    echo ""
    jetson_status
}

LOAD_SCRIPT=""

modules_load_all()
{
    # Read all scripts in modules
    for file in modules/* ; do
      if [ -f "$file" ] ; then
        # Load source
        source "$file"
        # Load all modules
        LOAD_SCRIPT+="$(echo $file):"
      fi
    done
}

# Start menu
MENU_SELECTION=menu_information

menu_information()
{
    if (whiptail --title "$(menu_title)" --yes-button "Start" --no-button "exit" --yesno "$(system_info)" 25 60)
    then
        #Execute configuration menu
        MENU_SELECTION=menu_configuration   
    else
        # Quit the script
        MENU_SELECTION=0
    fi
}

submenu_configuration()
{
    # Load source
    source "$1"
    # Execute the function with the same name    
    local FUNC=$(echo $1 | cut -f2 -d "/")
    # Check if exist the function   
    if type ${FUNC} &>/dev/null 
    then
        ${FUNC}
    else
        whiptail --title "$(menu_title)" --textbox /dev/stdin 10 60 <<< "DEFAULT - Submenu of $MODULE_NAME"
    fi
    # Print the choice
    echo "Your chosen option:" $MODULE_NAME
}

menu_configuration()
{
    local MENULIST=()
    local MENU_REFERENCE=()
    local COUNTER=1
    # Load first element in menu
    MENULIST+=("<--Back" "Turn to Information menu")
    MENU_REFERENCE+=("0" "")
    # Read modules
    for folder in modules/* ; do
      if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE="$folder"/$(echo $folder | cut -f2 -d "/").sh
        if [ -f $FILE ]
        then
            # Load source
            source "$FILE"
            # Add element in menu
            MENULIST+=("$COUNTER" "$MODULE_NAME")
            MENU_REFERENCE+=("$COUNTER" "$FILE")
            #Increase counter
            COUNTER=$((COUNTER+1))
        fi
      fi
    done
    # Load last element in menu
    MENULIST+=("Start-->" "Start install")
    # Evaluate the size
    local ARLENGTH
    let ARLENGTH=${#repoar[@]}
    # Load menu
    local OPTION=0
    while [[ $OPTION != "Start-->" && $OPTION != "<--Back" ]]
    do
        # Write the menu         
        OPTION=$(whiptail --title "Test Menu Dialog" --menu "Choose your option" 25 60 $ARLENGTH "${MENULIST[@]}" 3>&1 1>&2 2>&3)
        
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            # Load submenu only if is not "Start-->" or "<--Back"
            if [[ $OPTION != "Start-->" && $OPTION != "<--Back" ]]
            then
                submenu_configuration "${MENU_REFERENCE[$OPTION*2+1]}"
            fi
        else
            # You chose Cancel
            OPTION="<--Back"
        fi
    done
    
    case $OPTION in
        "<--Back")
            MENU_SELECTION=menu_information
            ;;
        "Start-->")
            MENU_SELECTION=menu_install
            ;;
        *)
            MENU_SELECTION=menu_information
            ;;
    esac
}

menu_install()
{
    whiptail --title "$(menu_title)" --textbox /dev/stdin 10 60 <<< "Installing ..."
    # Quit
    MENU_SELECTION=0
}


if [ ! -z ${JETSON_DESCRIPTION+x} ] || [ ! -z ${DEBUG+x} ]
then
    # Loop menu
    while [ $MENU_SELECTION != 0 ]
    do  
        # Load Menu
        ${MENU_SELECTION}
    done
    
else
    whiptail --title "$(menu_title)" --textbox /dev/stdin 10 60 <<< "$(system_info)" 
fi

