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

# Change the hostname module

MODULE_NAME="Set hostname"
MODULE_DESCRIPTION="Set a new hostname for the board."
MODULE_DEFAULT="STOP"
MODULE_OPTIONS=("RUN" "STOP")
MODULE_SUBMENU=("Write new hostname:new_hostname")

script_run()
{
    if [ ! -z ${NEW_HOSTNAME+x} ] ; then
        if [ $NEW_HOSTNAME != $HOSTNAME ] ; then
            echo "Change hostname in /etc/hostname"
            echo "$NEW_HOSTNAME" | sudo tee /etc/hostname
            echo "Change hostname in /etc/hosts"
            local HOSTS=$(cat /etc/hosts)
            # Update reference
            HOSTS="${HOSTS/$HOSTNAME/$NEW_HOSTNAME}"
            sudo echo "$HOSTS" | sudo tee /etc/hosts
            echo "Enable require reboot"
            MODULES_REQUIRE_REBOOT=1
        else
            echo "Hostname already setted $HOSTNAME"
        fi
    else
        echo "No NEW_HOSTNAME has setted"
    fi
}

script_load_default()
{
    if [ -z ${NEW_HOSTNAME+x} ] ; then
        # Write hostname
        NEW_HOSTNAME=$HOSTNAME
    fi
}

script_save()
{
    if [ ! -z ${NEW_HOSTNAME+x} ] ; then
        if [ $NEW_HOSTNAME != $HOSTNAME ] ; then
            echo "NEW_HOSTNAME=\"$NEW_HOSTNAME\"" >> $1
        fi
    fi
}

script_info()
{
    if [ ! -z ${NEW_HOSTNAME+x} ] ; then
        if [ $NEW_HOSTNAME != $HOSTNAME ] ; then
            echo " - New hostname: $NEW_HOSTNAME"
        fi
    fi
}

new_hostname()
{
    if [ -z ${NEW_HOSTNAME+x} ] ; then
        # Write hostname
        NEW_HOSTNAME=$HOSTNAME
    fi
    
    local HOSTNAME_TMP_VALUE
    HOSTNAME_TMP_VALUE=$(whiptail --inputbox "Set new hostname" 8 78 $NEW_HOSTNAME --title "New hostname" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new hostname
        NEW_HOSTNAME=$HOSTNAME_TMP_VALUE
    fi
}

