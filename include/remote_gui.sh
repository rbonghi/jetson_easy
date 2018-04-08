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
MENU_REMOTE_SELECTION=menu_remote_user_host

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
        
        # Load to host
        local REMOTE=$(remote_check_host $MODULE_PASSWORD)
        # Check if load start
        if [ $REMOTE == "YES" ] ; then
            # Load system and connect
            remote_connect $MODULE_PASSWORD
            # Quit the system
            MENU_REMOTE_SELECTION=0
        else
            # Initialize remote menu
            MENU_REMOTE_SELECTION=menu_remote_user_host
        fi
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
        MODULE_REMOTE_USER="user"
    fi
    
    if [ -z $MODULE_REMOTE_HOST ] ; then
        MODULE_REMOTE_HOST="remote"
    fi
    
    local pre_data=""
    if [ $MODULE_REMOTE_USER != "user" ] || [ $MODULE_REMOTE_HOST != "remote" ] ; then
        pre_data="$MODULE_REMOTE_USER@$MODULE_REMOTE_HOST"
    fi
    
    host_reference_tmp=$(whiptail --inputbox "Write the remote reference of your jetson with:
$MODULE_REMOTE_USER@$MODULE_REMOTE_HOST" 8 78 "$pre_data" --title "Remote Address" 3>&1 1>&2 2>&3)
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

