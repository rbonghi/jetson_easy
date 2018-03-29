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

MODULES_LIST=""
MODULES_FOLDER="modules"
MODULES_CONFIG="setup.txt"

# --------------------------------
# LOAD_MODULES
# --------------------------------

modules_sort()
{
    local MODULES_LIST_ARRAY
    # transform list in array
    IFS=$':' MODULES_LIST_ARRAY=($MODULES_LIST)
    # sort the array
    IFS=$'\n' MODULES_LIST_ARRAY=($(sort <<<"${MODULES_LIST_ARRAY[*]}"))
    # Re arrange array in list with delimiter ":"
    MODULES_LIST=$(echo ${MODULES_LIST_ARRAY[*]} | sed -e "s/ /:/g")
}

modules_load_default()
{
    # Read modules
    for folder in $MODULES_FOLDER/* ; do
        if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE_NAME=$(echo $folder | cut -f2 -d "/")
        local FILE="$folder"/$FILE_NAME.sh
            if [ -f $FILE ] ; then
                # Unset save function
                unset -f script_load_default
                # Load source
                source "$FILE"
                 # If a default module
                if [ $MODULE_DEFAULT -eq 1 ] ; then
                    MODULES_LIST+="$FILE_NAME:"
                fi
                # Check if exist the function
                if type script_load_default &>/dev/null
                then
                    script_load_default
                    # Load initialization variable function
                    echo "Load Default variable for: $MODULE_NAME"
                fi
            fi
        fi
    done
    # Sort all modules
    modules_sort
}

modules_load()
{
    if [ ! -z $1 ] ; then
        MODULES_CONFIG=$1
    fi
    
    if [ -f $MODULES_CONFIG ] ; then
        echo "Setup \"$MODULES_CONFIG\" found!"
        # Load all default values
        modules_load_default
        # Load and overwrite with setup file
        source $MODULES_CONFIG
        # Sort all modules
        modules_sort
    else
        echo "Setup \"$MODULES_CONFIG\" NOT found! Load default"
        modules_load_default
    fi
}

modules_save()
{
    if [ -z $1 ] ; then
        MODULES_CONFIG="setup.txt"
    else
        MODULES_CONFIG=$1
    fi
    
    echo "# Configuration Biddibi boddibi Boo" > $MODULES_CONFIG
    echo "# Author: Raffaello Bonghi" >> $MODULES_CONFIG
    echo "# Email: raffaello@rnext.it" >> $MODULES_CONFIG
    echo "" >> $MODULES_CONFIG
    
    echo "# List of availables modules" >> $MODULES_CONFIG
    echo "MODULES_LIST=\"$MODULES_LIST\"" >> $MODULES_CONFIG
    
    echo "" >> $MODULES_CONFIG
    echo "# ----------------------------- " >> $MODULES_CONFIG
    echo "# -     Modules variables     - " >> $MODULES_CONFIG
    echo "# ----------------------------- " >> $MODULES_CONFIG
    echo "" >> $MODULES_CONFIG
    for folder in $MODULES_FOLDER/* ; do
      if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE_NAME=$(echo $folder | cut -f2 -d "/")
        local FILE="$folder"/$FILE_NAME.sh
        if [ -f $FILE ] ; then
            # Unset save function
            unset -f script_save
            # Load source
            source "$FILE"
            # Check if exist the function
            if type script_save &>/dev/null
            then
                # Write name module
                echo "# Variables for: $MODULE_NAME" >> $MODULES_CONFIG
                # Save script
                script_save $MODULES_CONFIG
                # Add space
                echo "" >> $MODULES_CONFIG
            fi
        fi
      fi
    done
    
    echo "Save in $MODULES_CONFIG"
}

modules_isInList()
{
    IFS=':' read -ra MODULE <<< "$MODULES_LIST"
    for mod in "${MODULE[@]}"; do
        if [ "$mod" == $1 ] ; then
            echo "1"
            return
        fi
    done
    # Otherwise return 0
    echo "0"
}

modules_add()
{
    # Check if the module is in list otherwise add the new module
    echo $MODULES_LIST
    echo $1
    if [[ $MODULES_LIST != *"$1"* ]] ; then
        # Add new element
        echo "Add new module $1"
        MODULES_LIST+=":$1"
        # Sort all modules
        modules_sort
    else
        echo "Module $1 is already in list"
    fi
}

modules_remove()
{
    # Remove from list
    MODULES_LIST=$(echo $MODULES_LIST | sed -e "s/$1//g")
    # Sort all modules
    modules_sort
}

modules_run()
{
    source include/exesudo.sh
    
    if [ ! -z $MODULES_LIST ] ; then
        echo "Start install script..."
        IFS=':' read -ra MODULE <<< "$MODULES_LIST"
        for mod in "${MODULE[@]}"; do
            # Check if exist the same file with the name of the folder
            local FILE="$MODULES_FOLDER/$mod/$mod.sh"
            if [ -f $FILE ] ; then
                # Unset save function
                unset -f script_run
                # Load source
                source "$FILE"
                # Write name module
                echo "Running module - $MODULE_NAME"
                # Check if exist the function
                if type script_run &>/dev/null
                then
                    # run script
                    # exesudo script_run
                    script_run
                fi
            fi
        done
        echo "... Done"
    else
        echo "No modules"
    fi
}

modules_require_reboot()
{
    if [ -f /var/run/reboot-required ] || [ ! -z ${MODULES_REQUIRE_REBOOT+x} ] ; then
        echo "1"
    else
        echo "0"
    fi
}


