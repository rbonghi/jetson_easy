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

# Start menu
MENU_REMOTE_SELECTION=menu_remote_introduction

menu_remote_introduction()
{
    # Intro message
    menu_message_introduction
    # If all parameters are written the remote connection skip to the connection
    if [ ! -z $MODULE_REMOTE_USER ] && [ ! -z $MODULE_REMOTE_HOST ] && [ ! -z $MODULE_PASSWORD ] ; then
        MENU_REMOTE_SELECTION=menu_remote_info
    else
        MENU_REMOTE_SELECTION=menu_remote_user_host
    fi  
}

menu_remote_connect()
{
    # Load to host
    local REMOTE=$(remote_check_host)
    # Check if load start
    if [ $REMOTE == "YES" ] ; then
        # Load system and connect
        remote_connect
        # After exit remove the files
        remote_from_host
        # Quit the system
        MENU_REMOTE_SELECTION=0
    else
        # Initialize remote menu
        MENU_REMOTE_SELECTION=menu_remote_user_host
    fi
}

menu_remote_message()
{
    whiptail --title "$(menu_title)Biddibi Boddibi Boo" --textbox /dev/stdin 10 50 <<< "You are connected with:

host: $MODULE_REMOTE_HOST
user: $MODULE_REMOTE_USER
"
}

menu_remote_info()
{
    if (whiptail --title "$(menu_title)Biddibi Boddibi Boo" --no-button "edit" --yesno "Remote connection

host: $MODULE_REMOTE_HOST
user: $MODULE_REMOTE_USER

Do you want continue?" 12 50) then
        #Execute configuration menu
        MENU_REMOTE_SELECTION=menu_remote_connect
    else
        #Exit from menu
        MENU_REMOTE_SELECTION=menu_remote_user_host
    fi
}

menu_remote_pass()
{
    #Password Input
    psw=$(whiptail --title "Remote Password" --passwordbox "Enter your password for and choose Ok to continue.
    
user: $MODULE_REMOTE_USER
host: $MODULE_REMOTE_HOST" 10 60 3>&1 1>&2 2>&3)
    #Password
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save password
        MODULE_PASSWORD=$psw
        # Connect remotely
        menu_remote_connect
    else
        # Initialize remote menu
        MENU_REMOTE_SELECTION=menu_remote_user_host
    fi
}

menu_remote_user_host()
{
    # Load user and host reference
    local host_reference_tmp
    
    if [ -z $MODULE_REMOTE_USER ] ; then
        MODULE_REMOTE_USER="nvidia"
    fi
    
    if [ -z $MODULE_REMOTE_HOST ] ; then
        MODULE_REMOTE_HOST="tegra-ubuntu.local"
    fi
    
    local pre_data="$MODULE_REMOTE_USER@$MODULE_REMOTE_HOST"
    
    host_reference_tmp=$(whiptail --inputbox "Write the remote reference of your jetson follow user@host" 8 78 "$pre_data" --title "Remote Address" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new hostname
        remote_get_user_host $host_reference_tmp
        # Request pass
        MENU_REMOTE_SELECTION=menu_remote_pass
    else
        # Quit
        MENU_REMOTE_SELECTION=0
    fi
}

menu_remote()
{
    # Loop menu
    while [ $MENU_REMOTE_SELECTION != 0 ]
    do  
        # Load Menu
        ${MENU_REMOTE_SELECTION}
    done
}

