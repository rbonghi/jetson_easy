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

# Set default configuration of git

MODULE_NAME="Set default configuration of git"
MODULE_DESCRIPTION="Set GIT global configuration equal to user.name and user.email"
MODULE_DEFAULT=0
MODULE_SUBMENU=("Set user name:set_user_name" "Set email:set_email")

script_run()
{
    echo "Run git configuration"
    # Initialize rosdep
    tput setaf 6
    echo "Install git"
    tput sgr0
    sudo apt-get install git -y
    echo "git config --global user.name \"$NEW_GIT_USERNAME\""
    git config --global user.name "$NEW_GIT_USERNAME"
    echo "git config --global user.email $NEW_GIT_EMAIL"
    git config --global user.email $NEW_GIT_EMAIL
}

script_save()
{
    if [ ! -z ${NEW_GIT_USERNAME+x} ]
    then
        echo "NEW_GIT_USERNAME=\"$NEW_GIT_USERNAME\"" >> $1
    fi
    if [ ! -z ${NEW_GIT_EMAIL+x} ]
    then
        echo "NEW_GIT_EMAIL=\"$NEW_GIT_EMAIL\"" >> $1
    fi
    echo "Saved GIT parameters"
}

set_user_name()
{
    if [ -z ${NEW_GIT_USERNAME+x} ]
    then
        # Default git user name
        NEW_GIT_USERNAME="default"
    fi
    
    local NEW_GIT_USERNAME_TMP_VALUE
    NEW_GIT_USERNAME_TMP_VALUE=$(whiptail --inputbox "$MODULE_NAME - Set user name" 8 78 $NEW_GIT_USERNAME --title "Set user name" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new workspace
        NEW_GIT_USERNAME=$NEW_GIT_USERNAME_TMP_VALUE
    fi
}

set_email()
{
    if [ -z ${NEW_GIT_EMAIL+x} ]
    then
        # Default git user name
        NEW_GIT_EMAIL="default@default.com"
    fi
    
    local NEW_GIT_EMAIL_TMP_VALUE
    NEW_GIT_EMAIL_TMP_VALUE=$(whiptail --inputbox "$MODULE_NAME - Set email" 8 78 $NEW_GIT_EMAIL --title "Set email" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new workspace
        NEW_GIT_EMAIL=$NEW_GIT_EMAIL_TMP_VALUE
    fi
}


