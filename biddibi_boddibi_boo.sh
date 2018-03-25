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

# --------------------------------
# LOAD_MODULES
# --------------------------------

MODULES_LIST=""

modules_load_default()
{
    # Read modules
    for folder in modules/* ; do
      if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE_NAME=$(echo $folder | cut -f2 -d "/")
        local FILE="$folder"/$FILE_NAME.sh
        if [ -f $FILE ]
        then
            # Load source
            source "$FILE"
            # If a default module
            if [ $MODULE_DEFAULT -eq 1 ]
            then
                MODULES_LIST+="$FILE_NAME:"
            fi
        fi
      fi
    done
}

modules_isInList()
{
    IFS=':' read -ra MODULE <<< "$MODULES_LIST"
    for mod in "${MODULE[@]}"; do
        if [ "$mod" == $1 ]
        then
            echo "1"
            return
        fi
    done
    # Otherwise return 0
    echo "0"
}

# TODO temp

# Load all modules
modules_load_default
# Print list of modules
echo $MODULES_LIST

# --------------------------------
# GUI
# --------------------------------

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
    
    if [ -z ${JETSON_DESCRIPTION+x} ] ; 
    then
        echo ""
        echo ""
        echo "This is not a Jetson Board"
        echo "Please copy this repository in your Jetson board"
    else
        jetson_status
    fi
}

# Start menu
MENU_SELECTION=menu_information

submenu_default_check()
{
    if [ $1 == "YES" ]
    then
        if [ $defaultvar == "1" ]
        then
            echo "ON"
        else
            echo "OFF"
        fi
    else
        if [ $defaultvar == "0" ]
        then
            echo "ON"
        else
            echo "OFF"
        fi
    fi
}

submenu_default()
{
    # Load default status
    local  defaultvar=$1
    # Load enable variable
    local  __enablevar=$2
    
    #!/bin/bash
    DISTROS=$(whiptail --title "$MODULE_NAME" --radiolist \
    "$MODULE_DESCRIPTION
     
     Do you want run this script?" 15 60 2 \
    "YES" "launch all updates" $(submenu_default_check "YES") \
    "NO" "Stop upgrades" $(submenu_default_check "NO") 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        #echo "The chosen distro is:" $DISTROS
        eval $__enablevar="$DISTROS"
    else
        #echo "You chose Cancel."
        eval $__enablevar="-1"
    fi
    
}

submenu_configuration()
{
    # Load source
    source "$1"
    # Load the function with the same name    
    local FUNC=$(echo $1 | cut -f2 -d "/")
    # Save the name of the function
    local NAME=$(echo $FUNC | cut -f1 -d ".")
    # Check if exist the function   
    if type ${FUNC} &>/dev/null 
    then
        # Launch the function
        ${FUNC} $(modules_isInList $NAME) STATUS
        echo "Return value: $STATUS"
    else
        # Load default_menu to enable/disable this script
        submenu_default $(modules_isInList $NAME) STATUS
        echo "Return value: $STATUS"
    fi
    # Print the choice
    # echo "Your chosen option:" $MODULE_NAME
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
        OPTION=$(whiptail --title "$(menu_title) - Setup" --menu "Choose your option" 25 60 $ARLENGTH "${MENULIST[@]}" 3>&1 1>&2 2>&3)
        
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

menu_install()
{
    whiptail --title "$(menu_title) - Install" --textbox /dev/stdin 10 60 <<< "Installing ..."
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

