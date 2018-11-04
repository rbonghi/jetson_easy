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
MODULE_REMOTE_CONFIG_NAME=""

remote_get_config()
{
    # Load file configuration, if is new get dafault name
    local file_config=""
    if [ -z $MODULE_REMOTE_CONFIG_NAME ] ; then
        file_config=$MODULES_CONFIG_NAME
    else
        file_config=$MODULE_REMOTE_CONFIG_NAME
    fi
    
    if sshpass -p "$MODULE_PASSWORD" ssh $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST stat /tmp/jetson_easy/$file_config \> /dev/null 2\>\&1 ; then
        # Get back the remote config
        local configuration=""
        if [ $(basename $MODULES_CONFIG_FILE) != $file_config ]; then
            # The file config is a folder
            configuration=$file_config/$MODULES_CONFIG_NAME
        else
            # The file config is a file
            configuration=$file_config
        fi
        sshpass -p "$MODULE_PASSWORD" scp $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST:/tmp/jetson_easy/$configuration $MODULES_CONFIG_FILE
        # Execute load configuration
        modules_load
        # Save new setup
        modules_save
    fi
}

remote_find_jetson()
{
    # Find all jetson in network
    local list=$(nmap -sP 192.168.1.1/24)
    # Initialize global vector
    MODULE_REMOTE_FIND_LIST=()
    # Add Manual entry
    MODULE_REMOTE_FIND_LIST+=("Manual" "Write manually the address")
    # Get all tegra boards availables
    local tegra_list=$(echo $list | grep "tegra")
    # Get all jetson boards availables
    local jetson_list=$(echo $list | grep "jetson")
    # Read all lines
    local line
    while read line ; do 
        # Export name from list
        local name=${line#"Nmap scan report for "}
        name=$(echo $name | cut -d " " -f1 )
        # Get IP address
        local address=$(echo $line | cut -d "(" -f2 | cut -d ")" -f1)
        MODULE_REMOTE_FIND_LIST+=("$address" "$name")
        #echo $address - $name
    done <<< "$tegra_list
$jetson_list"
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
    # If exist temporary jetson_easy folder remove
    if [ -d /tmp/jetson_easy ] ; then
        rm -R /tmp/jetson_easy
    fi
    # build a folder
    mkdir -p /tmp/jetson_easy
    # Copy all folders
    cp -rf include /tmp/jetson_easy
    cp -rf jetson /tmp/jetson_easy
    cp -rf modules /tmp/jetson_easy
    cp -rf biddibi_boddibi_boo.sh /tmp/jetson_easy
    cp -rf LICENSE /tmp/jetson_easy
    cp -rf README.md /tmp/jetson_easy
    
    if [ $MODULES_CONFIG_PATH != $(pwd) ] ; then
    	# Copy folder
    	cp -rf $MODULES_CONFIG_PATH /tmp/jetson_easy
    	# Save configuration 
    	MODULE_REMOTE_CONFIG_NAME="$(basename $MODULES_CONFIG_PATH)"
    elif [ -f $MODULES_CONFIG_FILE ] ; then
    	#Copy only the config file
    	cp -rf $MODULES_CONFIG_FILE /tmp/jetson_easy
    	# Save configuration
    	MODULE_REMOTE_CONFIG_NAME="$(basename $MODULES_CONFIG_FILE)"
    fi
    
    # Move to temp folder
    local old=$(pwd)
    cd /tmp
    # Tar all selected files
    tar -czf /tmp/jetson_easy.tar.gz jetson_easy
    # Remove bkp folder
    rm -R jetson_easy
    # Go to origin folder
    cd $old

    # Create folder
    sshpass -p "$MODULE_PASSWORD" ssh $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST '
if [ -d /tmp/jetson_easy ] ; then
    rm -R /tmp/jetson_easy
fi
'
    # Copy file to remote
    sshpass -p "$MODULE_PASSWORD" scp /tmp/jetson_easy.tar.gz $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST:/tmp
    # Uncompress the file
    sshpass -p "$MODULE_PASSWORD" ssh $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST '
# Move to folder
cd /tmp
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
    
    # Load all script in remote board
    remote_load_to_host $MODULE_PASSWORD
    
    local STATUS=1
    local PAGE_MENU="menu_information"
    local config_file=""
    # If MODULE_REMOTE_CONFIG_NAME exist add option -c
    if [ ! -z $MODULE_REMOTE_CONFIG_NAME ] ; then
        config_file="-c $MODULE_REMOTE_CONFIG_NAME"
    fi
    
    while [ $STATUS != 0 ] ; do        
        # Start in remote the biddibi_boddibi_boo script
        sshpass -p "$MODULE_PASSWORD" ssh -t $MODULE_REMOTE_USER@$MODULE_REMOTE_HOST bash -ic "'
#Move to Jetson easy folder
cd /tmp/jetson_easy
# Launch biddibi_boddibi_boo in remote
./biddibi_boddibi_boo.sh -x $PAGE_MENU -p $MODULE_PASSWORD $config_file $OPTIONS

'"
        # Save result status
        STATUS=$?
        # Check if exit with request on save config
        case $STATUS in 
            15) 
                # Save the last config to server
                remote_get_config
                # Load save page
                PAGE_MENU="menu_save"
                ;;
            *)  # Load information page
                PAGE_MENU="menu_information"
                ;;
        esac
    done
}

