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

LOAD_SCRIPT=""
CONFIG_SAVED=0
    
load_all_modules()
{
    # Read all scripts in modules
    for file in modules/* ; do
      if [ -f "$file" ] ; then
        # Load source
        source "$file"
        # Loadd all installing scripts
        if [ $MODULE_DEFAULT -eq 1 ]
        then
            LOAD_SCRIPT+="$(echo $file):"
        fi
      fi
    done
}

save_setup()
{
    echo "LOAD_SCRIPT=\"$LOAD_SCRIPT\"" > setup.txt
    CONFIG_SAVED=1
}

load_modules()
{
    if [ -f setup.txt ]
    then
        echo "Setup found!"
        source setup.txt
    else
        echo "Setup NOT found!"
        load_all_modules
    fi
}

modify_list_modules()
{
    local NEW_LOAD_SCRIPT=""
    local COUNTER=$1
    # Read all scripts in modules
    for file in modules/* ; do
       # Move the cursor in the position
       tput cup $((COUNTER)) $2
       # Read the value
       IFS='' read -r -n1 ans
       #read -d'' -s -n1 ans
       if [ "${ans,,}" == "x" ]
       then
            NEW_LOAD_SCRIPT+="$(echo $file):"
       elif [ "$ans" == "" ]
       then
            if [ "$(check_ifis_inlist "$file")" == "X" ]
            then
                NEW_LOAD_SCRIPT+="$(echo $file):"
            fi
       fi
       # Increase counter
       COUNTER=$((COUNTER+1))
    done
    LOAD_SCRIPT=$NEW_LOAD_SCRIPT
}

check_ifis_inlist()
{
    IFS=':' read -ra ADDR <<< "$LOAD_SCRIPT"
    for i in "${ADDR[@]}"; do
        # process "$i"
        if [ "$i" == $1 ]
        then
            echo "X"
            return
        fi
    done
    # else return empty
    echo " "
    return
}

# Build the list of all avalables installing script modules
print_all_modules()
{
    local COUNTER=1
    # Read all scripts in modules
    for file in modules/* ; do
      if [ -f "$file" ] ; then
        # Load source
        source "$file"
        echo "  $COUNTER. [$(check_ifis_inlist "$file")] $MODULE_NAME"
        
        # DEBUG
        # echo " Name script $(echo "$file" | cut -f2 -d '-')"
        
        # Increase counter
        COUNTER=$((COUNTER+1))
      fi
    done
}

