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
# Reference
# Thanks @jetsonhacks
# https://github.com/jetsonhacks/installROSTX2/blob/master/installROS.sh

ros_is_check()
{
    local VAR=$1
    if [ -z ${VAR+x} ] ; then
        echo " "
    else
        if [ $VAR == "1" ] ; then
            echo "X"
        else
            echo " "
        fi
    fi
}

ros_load_version()
{
    local VAR=$1
    if [ -z ${VAR+x} ] ; then
        echo ""
    else
        echo "- $VAR"
    fi
}

# Default variables load
if [ -z ${ROS_NEW_DISTRO+x} ] ; then
    MODULE_NAME="Install ROS"
else
    MODULE_NAME="Install ROS $(ros_load_version $ROS_NEW_DISTRO)"
fi

MODULE_DESCRIPTION="Install ROS, set a new hostname and set a new master uri"
MODULE_DEFAULT=0

if [ -z ${ROS_NEW_DISTRO+x} ] || [ -z ${ROS_NEW_WORKSPACE+x} ] || [ -z ${ROS_NEW_HOSTNAME+x} ] ; then
    MODULE_SUBMENU=("Set distro:set_distro" "Set workspace:set_workspace" "[ ] Install workspace:write_workspace" "[ ] Set hostname:set_ros_hostname")
else
    MODULE_SUBMENU=("Set distro $(ros_load_version $ROS_NEW_DISTRO):set_distro" "Set workspace:set_workspace" "[$(ros_is_check $ROS_NEW_WORKSPACE)] Install workspace:write_workspace" "[$(ros_is_check $ROS_NEW_HOSTNAME)] Set hostname:set_ros_hostname" "Set ROS_MASTER_URI:set_master_uri")
fi

##################################################

ros_status()
{
    if [ ! -z ${ROS_DISTRO+x} ] ; then
        echo "(*) ROS $ROS_DISTRO:"
        echo "    - ROS_MASTER_URI: $ROS_MASTER_URI"
        if [ ! -z ${ROS_HOSTNAME+x} ] ; then
            echo "    - ROS_HOSTNAME: $ROS_HOSTNAME"
        fi
    else
        echo "(*) ROS Not installed!"
    fi
}

##################################################

script_run()
{
    # Load ROS installer source
    source ros_installer.sh
    
    # ROS Distro installer
    if [ ! -z ${ROS_NEW_DISTRO+x} ] ; then
        # Check if is already installed another ROS VERSION
        if [ -z ${ROS_DISTRO+x} ] ; then
            tput setaf 6
            echo "Install ROS $ROS_NEW_DISTRO"
            tput sgr0
            # Launch ROS installer
            install_ros
        else
            tput setaf 1
            echo "ROS $ROS_DISTRO is already installed"
            tput sgr0
        fi
    else
        tput setaf 1
        echo "Any ROS_DISTRO is selected"
        tput sgr0
    fi
    
    # ROS workspace installer
    if [ ! -z ${ROS_NEW_WORKSPACE+x} ] ; then
        if [ $ROS_NEW_WORKSPACE == "1" ] ; then
            tput setaf 6
            echo "Build new ROS workspace $NEW_ROS_WS"
            tput sgr0
            
            if [ -z $NEW_ROS_WS ] ; then
                NEW_ROS_WS="catkin_ws"
            fi
            
            # Launch New workspace installer
            install_workspace
        fi
    fi
    
    # ROS Variables
    if [ ! -z ${ROS_DISTRO+x} ] ; then
        # Check if empty the ROS_MASTER_URI
        if [ -z $ROS_NEW_MASTER_URI ] && [ $ROS_NEW_HOSTNAME=1 ] ; then
            ROS_NEW_MASTER_URI="http://$HOSTNAME.local:11311"
        fi
        # Update the ROS_MASTER_URI
        if [ $ROS_NEW_MASTER_URI != "http://localhost:11311" ] && [ $ROS_NEW_MASTER_URI != $ROS_MASTER_URI ]; then
            tput setaf 6
            echo "Add new ROS_MASTER_URI=\"$ROS_NEW_MASTER_URI\""
            tput sgr0
            grep -q -F "# ROS Configuration" $HOME/.bashrc || echo "# ROS Configuration" >> $HOME/.bashrc
            grep -q -F "export ROS_MASTER_URI=\"$ROS_NEW_MASTER_URI\"" $HOME/.bashrc || echo "export ROS_MASTER_URI=\"$ROS_NEW_MASTER_URI\"" >> $HOME/.bashrc
            
            if [ $ROS_NEW_HOSTNAME == 1 ] ; then
                tput setaf 6
                echo "Add new ROS_HOSTNAME=\"$HOSTNAME\""
                tput sgr0
                grep -q -F "export ROS_HOSTNAME=\"$HOSTNAME\"" $HOME/.bashrc || echo "export ROS_HOSTNAME=\"$HOSTNAME\"" >> $HOME/.bashrc
            fi
            
            tput setaf 6
            echo "Re run $USER bashrc in $HOME"
            tput sgr0
            source $HOME/.bashrc
        fi
    fi
}

script_load_default()
{
    # Write distribution
    if [ -z ${ROS_NEW_DISTRO+x} ] ; then
        ROS_NEW_DISTRO="kinetic"
    fi
    
    # Write default workspace
    if [ -z ${ROS_NEW_WS+x} ] ; then
        ROS_NEW_WS="catkin_ws"
    fi
    
    # Write is install workspace
    if [ -z ${ROS_NEW_WORKSPACE+x} ] ; then
        ROS_NEW_WORKSPACE=0
    fi
    
    # Write new ROS_NEW_HOSTNAME
    ROS_NEW_HOSTNAME=0
    
    # Write new ROS_NEW_MASTER_URI
    #if [ ! -z ${ROS_NEW_MASTER_URI+x} ] ; then
    #    ROS_NEW_MASTER_URI=$ROS_MASTER_URI
    #else
    #    ROS_NEW_MASTER_URI="http://localhost:11311"
    #fi
}

script_save()
{
    echo "ROS_NEW_DISTRO=\"$ROS_NEW_DISTRO\"" >> $1
    echo "ROS_NEW_WS=\"$ROS_NEW_WS\"" >> $1
    echo "ROS_NEW_WORKSPACE=\"$ROS_NEW_WORKSPACE\"" >> $1
    
    # Write new ROS_NEW_HOSTNAME
    echo "ROS_NEW_HOSTNAME=\"$ROS_NEW_HOSTNAME\"" >> $1
    
    # Write new ROS_NEW_MASTER_URI
    if [ ! -z ${ROS_NEW_MASTER_URI+x} ] ; then
        if [ "$ROS_NEW_MASTER_URI" != "$ROS_MASTER_URI" ] ; then
            echo "ROS_NEW_MASTER_URI=\"$ROS_NEW_MASTER_URI\"" >> $1
        fi
    fi
}

script_info()
{
    if [ $ROS_NEW_WORKSPACE = 1 ] ; then
        echo " - Add new workspace: $ROS_NEW_WS"
    fi
    
    if [ $ROS_NEW_HOSTNAME = 1 ] ; then
        echo " - ROS_MASTER_URI same $HOSTNAME"
    fi
    if [ ! -z ${ROS_NEW_MASTER_URI+x} ] ; then
        if [ "$ROS_NEW_MASTER_URI" != "$ROS_MASTER_URI" ] ; then
            echo " - New ROS_MASTER_URI: $ROS_NEW_MASTER_URI"
        fi
    fi
}

ros_load_check()
{
    if [ $1 == "YES" ]
    then
        if [ $2 == "1" ]
        then
            echo "ON"
        else
            echo "OFF"
        fi
    else
        if [ $2 == "0" ]
        then
            echo "ON"
        else
            echo "OFF"
        fi
    fi
}

ros_load_equal()
{
    if [ $1 == $2 ] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

ros_get_check()
{
    if [ $1 == "YES" ]
    then
        echo "1"
    else
        echo "0"
    fi
}

write_workspace()
{
    local ROS_NEW_WORKSPACE_TMP_VALUE
    ROS_NEW_WORKSPACE_TMP_VALUE=$(whiptail --title "$MODULE_NAME" --radiolist \
    "Do you want install the workspace?" 15 60 2 \
    "YES" "Install the workspace" $(ros_load_check "YES" $ROS_NEW_WORKSPACE) \
    "NO" "Skipp installation" $(ros_load_check "NO" $ROS_NEW_WORKSPACE) 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        ROS_NEW_WORKSPACE=$(ros_get_check $ROS_NEW_WORKSPACE_TMP_VALUE)
    fi
    
}

set_distro()
{
    local ROS_NEW_DISTRO_TMP_VALUE
    ROS_NEW_DISTRO_TMP_VALUE=$(whiptail --title "Set distribution" --radiolist \
    "Set ROS distribution" 15 60 2 \
    "kinetic" "Install the workspace" $(ros_load_equal "kinetic" $ROS_NEW_DISTRO) \
    "lunar" "Skipp installation" $(ros_load_equal "lunar" $ROS_NEW_DISTRO) 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new distribution
        ROS_NEW_DISTRO=$ROS_NEW_DISTRO_TMP_VALUE
    fi
}

set_master_uri()
{
    # Write new ROS_NEW_MASTER_URI
    if [ -z ${ROS_NEW_MASTER_URI+x} ] ; then
        if [ -z ${ROS_MASTER_URI+x} ] ; then
            ROS_NEW_MASTER_URI="http://localhost:11311"
        else
            ROS_NEW_MASTER_URI=$ROS_MASTER_URI
        fi
    fi
    
    if [ $ROS_NEW_HOSTNAME == 1 ] ; then
        ROS_NEW_MASTER_URI="http://$HOSTNAME.local:11311"
    fi
    
    local ROS_NEW_MASTER_URI_TMP
    ROS_NEW_MASTER_URI_TMP=$(whiptail --inputbox "Set ROS_MASTER_URI" 8 78 $ROS_NEW_MASTER_URI --title "Set ROS_MASTER_URI" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write new ROS_MASTER_URI
        ROS_NEW_MASTER_URI=$ROS_NEW_MASTER_URI_TMP
    fi
}

set_ros_hostname()
{
    local ROS_NEW_HOSTNAME_TMP_VALUE
    ROS_NEW_HOSTNAME_TMP_VALUE=$(whiptail --title "$MODULE_NAME" --radiolist \
    "Do you want use same hostname?" 15 60 2 \
    "YES" "Use same hostname" $(ros_load_check "YES" $ROS_NEW_HOSTNAME) \
    "NO" "Manual edit" $(ros_load_check "NO" $ROS_NEW_HOSTNAME) 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        ROS_NEW_HOSTNAME=$(ros_get_check $ROS_NEW_HOSTNAME_TMP_VALUE)
    fi
    
}

set_workspace()
{
    local ROS_NEW_WS_TMP_VALUE
    ROS_NEW_WS_TMP_VALUE=$(whiptail --inputbox "Set ROS workspace" 8 78 $ROS_NEW_WS --title "Set ROS workspace" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new workspace
        ROS_NEW_WS=$ROS_NEW_WS_TMP_VALUE
    fi
}
