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

cl_remote()
{
    if [ -z $MODULE_REMOTE_USER ] ; then
        echo "empty user"
        
        local USER_HOST=""
        echo "Write the user@remote for your board?: "
        read USER_HOST
        remote_get_user_host $USER_HOST
    fi
    
    if [ -z $MODULE_PASSWORD ] ; then
        echo "empty password"
        
        echo "What is the password?: "
        read -s MODULE_PASSWORD
    fi
    
    # Check connection
    local CONNECTION=$(remote_check_host)
    
    echo "Connection to ..."
    echo "User: $MODULE_REMOTE_USER"
    echo "Host: $MODULE_REMOTE_HOST"
    
    if [ $CONNECTION == "YES" ] ; then
        # Load system and connect
        remote_connect -s
    fi
}

cl_host()
{
    # All modules are in MODULES_LIST
    echo "Module loaded:"
    echo $MODULES_LIST
    
    if [ ! -z $MODULE_PASSWORD ] ; then
        # Pass set
        $(echo $MODULE_PASSWORD | sudo -S -i true)
    fi
    
    # Run installer script
    echo "Module run:"
    modules_run
    
    if [ $(modules_require_reboot) == "1" ]
    then
        tput setaf 1
        echo "Reboot required!"
        tput sgr0

        if [ -z ${MODULE_REBOOT+x} ] ; then
            read -p "Do you want reboot? [Y/n]" -n 1 -r
            echo    # (optional) move to a new line
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                echo "REBOOOT"
                sudo reboot
            fi
        else
            echo "REBOOOT"
            sudo reboot
        fi
    fi
}

no_gui()
{
    if [ $MODULE_REMOTE == "1" ] ; then
		# Load remote script
        cl_remote
    else
        # Load host script
        cl_host
    fi
}
