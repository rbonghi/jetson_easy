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
MODULES_CONFIG=""

# --------------------------------
# LOAD_MODULES
# --------------------------------

modules_load_default()
{
    # Read modules
    for folder in $MODULES_FOLDER/* ; do
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
                MODULES_LIST+=":$FILE_NAME"
            fi
        fi
      fi
    done
    # remove first in the list
    MODULES_LIST=$(echo $MODULES_LIST | cut -f2- -d ":")
}

modules_load()
{
    if [ -z $1 ]
    then
        MODULES_CONFIG="setup.txt"
    else
        MODULES_CONFIG=$1
    fi
    
    if [ -f $MODULES_CONFIG ]
    then
        echo "Setup \"$MODULES_CONFIG\" found!"
        source $MODULES_CONFIG
    else
        echo "Setup \"$MODULES_CONFIG\" NOT found! Load default"
        modules_load_default
    fi
}

modules_save()
{
    if [ -z $1 ]
    then
        MODULES_CONFIG="setup.txt"
    else
        MODULES_CONFIG=$1
    fi
    
    echo "# Configuration Biddibi boddibi Boo" > $MODULES_CONFIG
    echo "# Author: Raffaello Bonghi" >> $MODULES_CONFIG
    echo "# Email: raffaello@rnext.it" >> $MODULES_CONFIG
    echo "" >> $MODULES_CONFIG
    
    for folder in $MODULES_FOLDER/* ; do
      if [ -d "$folder" ] ; then
        # Check if exist the same file with the name of the folder
        local FILE_NAME=$(echo $folder | cut -f2 -d "/")
        local FILE="$folder"/$FILE_NAME.sh
        if [ -f $FILE ]
        then
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
            fi
        fi
      fi
    done
    
    echo "# List of availables modules" >> $MODULES_CONFIG
    echo "MODULES_LIST=\"$MODULES_LIST\"" >> $MODULES_CONFIG
    
    echo "Save in $MODULES_CONFIG"
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

modules_add()
{
    if [ ! -z $MODULES_LIST ]
    then
        local NEW_MODULES_LIST=""
        if [ $(modules_isInList $1) == "0" ]
        then
            local mod
            local one_add="0"
            echo "Add new module $1"
            local IDX=$( echo $1 | cut -f1 -d "-" )
            # Build a reverse list
            local REVERSE_MODULES_LIST=$(echo $MODULES_LIST | awk -F ':' '{ for (i=NF; i>1; i--) printf("%s:",$i); print $1; }')
            # Build a new list add add in sequence
            IFS=':' read -ra MODULE <<< "$REVERSE_MODULES_LIST"
            for mod in "${MODULE[@]}"; do
                # Get counter index
                local COUNTER=$( echo $mod | cut -f1 -d "-" )
                # echo "$IDX - $COUNTER"
                if [ "$IDX" -ge "$COUNTER" ] && [ $one_add == "0" ]
                then
                    NEW_MODULES_LIST+="$1:$mod:"
                    # Add one time
                    one_add="1"
                elif [ "$IDX" -le "$COUNTER" ] && [ $one_add == "0" ]
                then
                    # Add before
                    NEW_MODULES_LIST+="$mod:$1:"
                    # Add one time
                    one_add="1"
                else
                    NEW_MODULES_LIST+="$mod:"
                fi
            done
            # Reoder list
            NEW_MODULES_LIST=$(echo $NEW_MODULES_LIST | awk -F ':' '{ for (i=NF; i>1; i--) printf("%s:",$i); print $1; }')
            NEW_MODULES_LIST=$(echo $NEW_MODULES_LIST | cut -f2- -d ":")
            #Update module list
            MODULES_LIST=$NEW_MODULES_LIST
        else
            echo "Module $1 is already in list"
        fi
    else
        # Add in list the first element
        echo "Add new module $1"
        MODULES_LIST+="$1"
    fi
}

modules_remove()
{
    if [ ! -z $MODULES_LIST ]
    then
        if [ $(modules_isInList $1) != "0" ]
        then
            local mod
            local NEW_MODULES_LIST=""
            echo "Remove module $1"
            # Build a new list add add in sequence
            IFS=':' read -ra MODULE <<< "$MODULES_LIST"
            for mod in "${MODULE[@]}"; do
                if [ $mod != $1 ]
                then
                    NEW_MODULES_LIST+=":$mod"
                fi
            done
            NEW_MODULES_LIST=$(echo $NEW_MODULES_LIST | cut -f2- -d ":")
            #Update module list
            MODULES_LIST=$NEW_MODULES_LIST
        else
            echo "Module $1 doesn't exist"
        fi
    else
        echo "Module $1 doesn't exist"
    fi
}


test_it_out ()
{
    local params=( "$@" )
    echo "Hello "$( whoami )"!"
    echo "You passed the following params:"
    printf "%s\n" "${params[@]}" ## print array
}

modules_run()
{
    source include/exesudo.sh
    
    if [ ! -z $MODULES_LIST ]
    then
        echo "Start install script..."
        IFS=':' read -ra MODULE <<< "$MODULES_LIST"
        for mod in "${MODULE[@]}"; do
            # Check if exist the same file with the name of the folder
            local FILE="$MODULES_FOLDER/$mod/$mod.sh"
            if [ -f $FILE ]
            then
                # Load source
                source "$FILE"
                # Write name module
                echo "Running module - $MODULE_NAME"
                # run script
                exesudo script_run
            fi
        done
        echo "... Done"
    else
        echo "No modules"
    fi
}

modules_require_reboot()
{
    if [ -f /var/run/reboot-required ]; then
        echo "1"
    else
        echo "0"
    fi
}


