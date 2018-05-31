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

# --------------------------------
# GUI
# --------------------------------

# Reference:
# http://manpages.ubuntu.com/manpages/xenial/man1/whiptail.1.html
# https://en.wikibooks.org/wiki/Bash_Shell_Scripting/Whiptail
# http://xmodulo.com/create-dialog-boxes-interactive-shell-script.html

# Variable to show the saved information status
GUI_SAVED=0



system_info()
{
    # Information about board
    menu_info
    
    # NVIDIA Jetson status
    jetson_status
    
    for folder in $MODULES_FOLDER/* ; do
      if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE_NAME=$(echo $folder | cut -f2 -d "/")
        local FILE="$folder"/$FILE_NAME.sh
        if [ -f $FILE ] ; then
            # Unset save function
            unset -f script_list
            # Load source
            source "$FILE"
            # Check if exist the function
            if type script_list &>/dev/null
            then
                # run script
                script_list
            fi
        fi
      fi
    done
}

# Start menu
MENU_SELECTION=menu_introduction

menu_introduction()
{
    # Skip show license if is the host in remote connection
    if [ -z $MODULE_IM_HOST ] ; then
        menu_message_introduction
    fi
    # Load information
    MENU_SELECTION=menu_information
}

submenu_load_check()
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

submenu_get_check()
{
    if [ $1 == "YES" ]
    then
        echo "1"
    else
        echo "0"
    fi
}

submenu_default()
{
    # Load default status
    local  defaultvar=$1
    # Load enable variable
    local  __enablevar=$2
    
    local default_value
    default_value=$(whiptail --title "$MODULE_NAME" --radiolist \
    "$MODULE_DESCRIPTION
     Do you want run this script?
     
[up arrow | down arrow] = Move on menu
[space] = Select option
[enter] = Save option" 17 60 2 \
    "YES" "launch all updates" $(submenu_load_check "YES") \
    "NO" "Stop upgrades" $(submenu_load_check "NO") 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        eval $__enablevar=$(submenu_get_check $default_value)
    else
        #echo "You chose Cancel."
        eval $__enablevar="-1"
    fi

}

submenu_extra()
{
    # Load enable variable
    local  __enablevar=$2
    
    local MENU_EXTRA=()
    local MENU_EXTRA_FUNC=()
    MENU_EXTRA+=("<--Back" "Turn to Information menu")
    MENU_EXTRA+=("Enable" "Enable or disable this module")
    MENU_EXTRA_FUNC+=("0")
    local COUNTER=1
    local sub_element
    for sub_element in "${MODULE_SUBMENU[@]}"
    do
        local name=$(echo $sub_element | cut -f1 -d ":")
        local func=$(echo $sub_element | cut -f2 -d ":")
        MENU_EXTRA+=("$COUNTER" "$name")
        MENU_EXTRA_FUNC+=("$func")
        #Increase counter
        COUNTER=$((COUNTER+1))
    done
    
    OPTION_EXTRA=$(whiptail --title "$MODULE_NAME" --menu "$MODULE_DESCRIPTION
    
    Choose your option" 22 60 $ARLENGTH "${MENU_EXTRA[@]}" 3>&1 1>&2 2>&3)
    
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Load submenu only if is not "Start-->" or "<--Back"
        if [ $OPTION_EXTRA == "Enable" ]
        then
            # Load default Enable menu
            submenu_default $1 STATUS
            #echo "You chose Cancel."
            eval $__enablevar="$STATUS"            
            # Load submenu
            submenu_configuration $3
            
        elif [ $OPTION_EXTRA != "<--Back" ]
        then
            # echo "Called $OPTION_EXTRA + ${MENU_EXTRA_FUNC[$OPTION_EXTRA]}"
            # Run extra menu
            ${MENU_EXTRA_FUNC[$OPTION_EXTRA]}
            # Load submenu
            submenu_configuration $3
        fi
    else
        # You chose Cancel
        OPTION_EXTRA="<--Back"
    fi
}

submenu_configuration()
{
    unset MODULE_SUBMENU
    # Load source
    source "$1"
    # Load the function with the same name    
    local FUNC=$(echo $1 | cut -f2 -d "/")
    # Save the name of the function
    local NAME=$(echo $FUNC | cut -f1 -d ".")
    # Check if exist the function
    if [ ! -z ${MODULE_SUBMENU+x} ]
    then
        # Launch the function
        # ${FUNC} $(modules_isInList $NAME) STATUS
        submenu_extra $(modules_isInList $NAME) STATUS $1
    else
        # Load default_menu to enable/disable this script
        submenu_default $(modules_isInList $NAME) STATUS
    fi
    # echo "Return value: $STATUS"
    # Add or remove the module in list
    case $STATUS in
        "1") # Add module
             modules_add $NAME
             # Load default variables
             # script_load_default 
             ;;
        "0") modules_remove $NAME ;;
        *) ;;
    esac
}

menu_checkIfLoaded()
{
    # Check if the module is in List
    if [ $(modules_isInList $FILE_NAME) == "1" ]
    then
        echo "X"
    else
        echo " "
    fi
}

MENU_LIST=()
MENU_REFERENCE=()

menu_load_list()
{
    local folder
    MENU_LIST=()
    MENU_REFERENCE=()
    local COUNTER=1
    # Load first element in menu
    MENU_LIST+=("<--Back" "Turn to Information menu")
    MENU_REFERENCE+=("0" "")
    # Read modules
    for folder in $MODULES_FOLDER/* ; do
      if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE_NAME=$(echo $folder | cut -f2 -d "/")
        local FILE="$folder"/$FILE_NAME.sh
        if [ -f $FILE ] ; then
            # unload variables
            unset MODULE_DEFAULT
            # Load source
            source "$FILE"
            # Add only all modules without MODULE_DEFAULT=-1
            if [ $MODULE_DEFAULT -ne -1 ] ; then
                # Add element in menu
                MENU_LIST+=("$COUNTER" "[$(menu_checkIfLoaded $FILE_NAME)] $MODULE_NAME")
                MENU_REFERENCE+=("$COUNTER" "$FILE")
                #Increase counter
                COUNTER=$((COUNTER+1))
            fi
        fi
      fi
    done
    # Load last element in menu
    MENU_LIST+=("Start-->" "Start install")
    # Load last element in menu
    MENU_LIST+=("Save" "Save configuration in $MODULES_CONFIG")
}

menu_configuration_menu()
{
    echo "You can configure your Jetson with different modules."
    #if [ $GUI_SAVED = 1 ] ; then
    #    echo "-- Configuration stored in $MODULES_CONFIG!"
    #else
    #    echo ""
    #fi
    echo "Choose your option:"
    echo "[up arrow | down arrow] = Move on menu"
    # echo "[space] = Select option"
    echo "[enter] = Option menu"
    # Clear GUI status information
    GUI_SAVED=0
}

menu_configuration()
{
    # Load menu
    local OPTION=0
    while [[ $OPTION != "Start-->" && $OPTION != "<--Back" ]]
    do
        # Load menu
        menu_load_list
        # Evaluate the size
        local ARLENGTH
        let ARLENGTH=${#repoar[@]}
        # Write the menu         
        OPTION=$(whiptail --title "$(menu_title)Setup" --menu "$(menu_configuration_menu)" 22 60 $ARLENGTH "${MENU_LIST[@]}" 3>&1 1>&2 2>&3)
        
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            # Load submenu only if is not "Start-->" or "<--Back"
            if [ $OPTION == "Save" ] ; then
                # Save modification
                modules_save $MODULES_CONFIG
                # Show message
                GUI_SAVED=1
                # Save only if is the local machine
                if [ $MODULE_IM_HOST == 1 ] ; then
                    # Save
                    exit 15
                fi
            elif [[ $OPTION != "Start-->" && $OPTION != "<--Back" ]] ; then
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
            MENU_SELECTION=menu_recap
            ;;
        *)
            MENU_SELECTION=menu_information
            ;;
    esac
}

menu_information()
{
    # Check if is a Jetson
    if [ ! -z ${JETSON_DESCRIPTION+x} ] || [ ! -z ${DEBUG+x} ] ; then
        if (whiptail --title "$(menu_title)Biddibi Boddibi Boo" --scrolltext --yes-button "Setup" --no-button "ESC" --yesno "$(system_info)" 22 60 3>&1 1>&2 2>&3) then
            #Execute configuration menu
            MENU_SELECTION=menu_configuration
        else
            #Exit from menu
            MENU_SELECTION=0
        fi
    else
        whiptail --title "$(menu_title)Biddibi Boddibi Boo" --textbox /dev/stdin 22 60 --ok-button "ESC" <<< "$(system_info)"
        #Exit from menu
        MENU_SELECTION=0
    fi
}

menu_launch_run()
{
    # Check if the root password if good
    sudo -k # make sure to ask for password on next sudo
    if $(echo $1 | sudo -S -i true); then
        # Run module
        modules_run
        # Move to recap menu
        MENU_SELECTION=menu_end
    fi
}

menu_install()
{
    if [ -z $MODULE_PASSWORD ] ; then
        #Password Input
        psw=$(whiptail --title "$(menu_title)SUDO Password" --passwordbox "Enter your password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)
        #Password If
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            # Launch run
            menu_launch_run $psw
        else
            #Execute configuration menu
            MENU_SELECTION=menu_configuration
        fi
    else
        # Launch run
        menu_launch_run $MODULE_PASSWORD
    fi
}

menu_list_installed()
{
    local folder
    # Read modules
    echo "Modules installed:"
    echo ""
    for folder in $MODULES_FOLDER/* ; do
      if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE_NAME=$(echo $folder | cut -f2 -d "/")
        local FILE="$folder"/$FILE_NAME.sh
        if [ -f $FILE ]
        then
            if [ $(modules_isInList $FILE_NAME) == "1" ]
            then
                # Unset save function
                unset -f script_info
                # Load source
                source "$FILE"
                # Add element in menu
                echo "[$(menu_checkIfLoaded $FILE_NAME)] $MODULE_NAME"
                # Check if exist the function
                if type script_info &>/dev/null
                then
                    # run script
                    script_info
                fi
            fi
        fi
      fi
    done
    
    if [ $(modules_require_reboot) == "1" ]
    then
        echo ""
        echo ""
        echo "    REBOOT REQUIRED!"
    fi
}

menu_recap()
{
    # If you cannot understand this, read Bash_Shell_Scripting#if_statements again.
    if (whiptail --title "$(menu_title)Recap" --yes-button "INSTALL" --no-button "exit" --yesno "$(menu_list_installed)" 22 60) then
        # Launch installer
        MENU_SELECTION=menu_install
    else
        # Launch installer
        MENU_SELECTION=menu_configuration
    fi

}

menu_end()
{
    if [ $(modules_require_reboot) == "1" ]
    then
        if [ -z ${MODULE_REBOOT+x} ] ; then
            # If you cannot understand this, read Bash_Shell_Scripting#if_statements again.
            if (whiptail --title "$(menu_title)Recap" --yes-button "REBOOT" --no-button "exit" --yesno "$(menu_list_installed)" 22 60) then
                echo "System rebotting ... "
                sudo reboot
            else
                echo "System require a reboot!"
            fi
        else
            whiptail --title "$(menu_title)Recap" --ok-button "REBOOT" --textbox /dev/stdin 22 60 <<< "$(menu_list_installed)"
            echo "System rebotting ... "
            sudo reboot
        fi
    else
        whiptail --title "$(menu_title)Recap" --textbox /dev/stdin 22 60 <<< "$(menu_list_installed)"
    fi
    # Quit
    MENU_SELECTION=0
}

menu_loop()
{
    # Loop menu
    while [ $MENU_SELECTION != 0 ]
    do  
        # Load Menu
        ${MENU_SELECTION}
    done
}



