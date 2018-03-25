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

# Install ROS

MODULE_NAME="Install ROS"
MODULE_DESCRIPTION="Install ROS, set a new hostname and set a new master uri"
MODULE_DEFAULT=0
MODULE_SUBMENU=("Set distro:set_distro" "Install workspace:write_workspace")

script_run()
{
    echo "Run script ..."
}

script_save()
{
    if [ ! -z ${ROS_DISTRO+x} ]
    then
        echo "ROS_DISTRO=\"$ROS_DISTRO\"" >> $1
        echo "Saved ROS parameters"
    fi
}

set_distro()
{
    if [ -z ${ROS_DISTRO+x} ]
    then
        # Write hostname
        ROS_DISTRO="kinetic"
    fi
    
    ROS_DISTRO_TMP_VALUE=$(whiptail --inputbox "Set distribution" 8 78 $ROS_DISTRO --title "Set ROS distribution" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new hostname
        ROS_DISTRO=$ROS_DISTRO_TMP_VALUE
    fi
}

write_workspace()
{
    HOSTNAME_TMP_VALUE=$(whiptail --inputbox "Set new hostname" 8 78 VERDE --title "New hostname" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new hostname
        echo "HELLO"
    fi
}
