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

# Reference
# https://zaiste.net/posts/a_few_ways_to_execute_commands_remotely_using_ssh/
# https://www.cyberciti.biz/faq/linux-unix-applesox-ssh-password-on-command-line/
# https://stackoverflow.com/questions/22078806/checking-ssh-failure-in-a-script?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa

MODULE_REMOTE_USER=""
MODULE_REMOTE_HOST=""

remote_get_config()
{
    if sshpass -p "$MODULE_PASSWORD" ssh $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST stat /tmp/jetson_easy/setup.txt \> /dev/null 2\>\&1
    then
        # Get back the remote config
        sshpass -p "$MODULE_PASSWORD" scp $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST:/tmp/jetson_easy/setup.txt $MODULES_CONFIG
        # Execute load configuration
        modules_load
        # Save new setup
        modules_save
    fi
}

remote_get_user_host()
{
    MODULE_REMOTE_USER=$(echo "$1" |  cut -f1 -d "@" )
    MODULE_REMOTE_HOST=$(echo "$1" |  cut -f2 -d "@" )
    
    if [ $MODULE_REMOTE_USER == $MODULE_REMOTE_HOST ] ; then
        MODULE_REMOTE_USER=$USER
    fi
}

remote_check_host()
{
    if (sshpass -p "$MODULE_PASSWORD" ssh -q -o "StrictHostKeyChecking no" $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST exit) ; then
        echo "YES"
    else
        echo "NO"
    fi
}

remote_from_host()
{
    # Remove the folder
    sshpass -p "$MODULE_PASSWORD" ssh $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST rm -r /tmp/jetson_easy
}

remote_load_to_host()
{
    local REFERENCE_CONFIG=""
    # Copy reference only if exist the file
    if [ -f $MODULES_CONFIG ] ; then
        REFERENCE_CONFIG=$MODULES_CONFIG
    fi
    
    local CONFIG_FOLDER=""
    # Copy reference only if exist the file
    if [ -d config ] ; then
        CONFIG_FOLDER="config"
    fi
    
    # Tar all selected files
    tar -czf /tmp/jetson_easy.tar.gz include jetson modules biddibi_boddibi_boo.sh LICENSE README.md $REFERENCE_CONFIG $CONFIG_FOLDER

    # Create folder
    sshpass -p "$MODULE_PASSWORD" ssh $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST '
if [ -d /tmp/jetson_easy ] ; then
    rm -R /tmp/jetson_easy
fi
mkdir -p /tmp/jetson_easy
'
    # Copy file to remote
    sshpass -p "$MODULE_PASSWORD" scp /tmp/jetson_easy.tar.gz $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST:/tmp/jetson_easy
    # Uncompress the file
    sshpass -p "$MODULE_PASSWORD" ssh $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST '
# Move to folder
cd /tmp/jetson_easy
# Exctract archive
tar -xf jetson_easy.tar.gz
# remove tar file
rm jetson_easy.tar.gz
'
    # Remote temp file
    rm /tmp/jetson_easy.tar.gz
}

remote_load_to_host_all()
{
    local CHECK=0
    
    while [ $CHECK != 1 ] ; do
        sshpass -p "$MODULE_PASSWORD" ssh $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST '
            if [ -d /tmp/jetson_easy ] ; then
                exit 0
            else
                exit 1
            fi   
        '
        case $? in
            0) echo "Remove old folder"
               remote_from_host
               ;;
            1) echo "Copy this folder"
               sshpass -p "$MODULE_PASSWORD" scp -r . $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST:/tmp/jetson_easy
               CHECK=1
               ;;
           *) echo "Error connection"
               CHECK=1
               return 1
               ;;
        esac
    done
}

remote_connect()
{
    # Get all other options
    local OPTIONS=$@
    
    #echo "./biddibi_boddibi_boo.sh -p $PASSWORD $OPTIONS"
    
    # Load all script in remote board
    remote_load_to_host $MODULE_PASSWORD
    
    
    local STATUS=1
    local PAGE_MENU="menu_information"
    while [ $STATUS != 0 ] ; do        
        # Start in remote the biddibi_boddibi_boo script
        sshpass -p "$MODULE_PASSWORD" ssh -t $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST bash -ic "'
#Move to Jetson easy folder
cd /tmp/jetson_easy
# Launch biddibi_boddibi_boo in remote
./biddibi_boddibi_boo.sh -x $PAGE_MENU -p $MODULE_PASSWORD $OPTIONS

'"
        # Save result status
        STATUS=$?
        # Check if exit with request on save config
        case $STATUS in 
            15) 
                # Save the last config to server
                remote_get_config
                # Load configuration page
                PAGE_MENU="menu_configuration"
                ;;
            *)  # Load information page
                PAGE_MENU="menu_information"
                ;;
        esac
    done
}

