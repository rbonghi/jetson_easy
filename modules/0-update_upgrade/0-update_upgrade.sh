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

# Update and upgrade
# How many updates are availables
# https://stackoverflow.com/questions/21949984/find-os-number-of-updates-available

MODULE_NAME="Update & Distribution upgrade & Upgrade"
MODULE_DESCRIPTION="Launch in order:
 - apt-get update
 - apt-get dist-upgrade
 - apt-get upgrade"
MODULE_DEFAULT="AUTO"

script_check()
{
    # Automatically update keys
    tput setaf 6
    echo 'APT KEY update starting...'
    tput sgr0
    sudo apt-key update
    
    local update_available=$(/usr/lib/update-notifier/apt-check 2>&1 | awk '-F;' 'END { print $1, $2 }')
    local pkg=$(echo $update_available | cut -d ' ' -f1)
    local sec=$(echo $update_available | cut -d ' ' -f2)
    if [ $pkg -gt "0" ] ; then
        return 1
    else
        return 0
    fi
}

script_list()
{
    local update_available=$(/usr/lib/update-notifier/apt-check 2>&1 | awk '-F;' 'END { print $1, $2 }')
    local pkg=$(echo $update_available | cut -d ' ' -f1)
    local sec=$(echo $update_available | cut -d ' ' -f2)
    if [ $pkg -gt "0" ] ; then
        echo "(*) Update required:"
        echo "    - $pkg packages can be updated"
        echo "    - $sec updates are security updates"
    fi
}

script_run()
{
    # Automatically update keys
    tput setaf 6
    echo 'APT KEY update starting...'
    tput sgr0
    sudo apt-key update

    # Automatically clean
    tput setaf 6
    echo 'APT clean starting...'
    tput sgr0
    sudo apt-get clean

    # Automatically update all packages
    tput setaf 6
    echo 'APT update starting...'
    tput sgr0
    sudo apt-get update
    
    # Automatically distributive upgrade all packages
    tput setaf 6
    echo 'APT distributive upgrade starting...'
    tput sgr0
    sudo apt-get -y dist-upgrade --allow-unauthenticated
    
    # Automatically upgrade all packages
    tput setaf 6
    echo 'APT upgrade starting...'
    tput sgr0
    sudo apt-get -y dist-upgrade
    
    # Automatically remove packages
    tput setaf 6
    echo 'APT autoremove starting...'
    tput sgr0
    sudo apt-get -y autoremove --allow-unauthenticated
    
    tput setaf 6
    echo 'END'
    tput sgr0
}


