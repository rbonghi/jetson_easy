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

MODULE_NAME="Install ROS $(ros_load_version $NEW_ROS_DISTRO)"
MODULE_DESCRIPTION="Install ROS, set a new hostname and set a new master uri"
MODULE_DEFAULT=0
MODULE_SUBMENU=("Set distro $(ros_load_version $NEW_ROS_DISTRO):set_distro" "Set workspace:set_workspace" "[$(ros_is_check $NEW_WORKSPACE)] Install workspace:write_workspace")

install_ros()
{
    # Setup sources.lst
    tput setaf 6
    echo 'Setup sources.lst'
    tput sgr0
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

    # Setup keys
    tput setaf 6
    echo 'Setup keys'
    tput sgr0
    sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

    # Automatically update all packages
    tput setaf 6
    echo 'APT update starting...'
    tput sgr0
    sudo apt-get update

    # Install ROS 
    tput setaf 6
    echo "Install ROS ros-$NEW_ROS_DISTRO-ros-base"
    tput sgr0
    sudo apt-get install ros-$NEW_ROS_DISTRO-ros-base -y

    # Initialize rosdep
    tput setaf 6
    echo "Install ROS python-rosdep"
    tput sgr0
    sudo apt-get install python-rosdep -y

    # Certificates are messed up on the Jetson for some reason
    tput setaf 6
    echo "Rehash certificates"
    tput sgr0
    sudo c_rehash /etc/ssl/certs

    # Initialize rosdep
    tput setaf 6
    echo "Rosdep init"
    tput sgr0
    sudo rosdep init
    
    # To find available packages, use:
    tput setaf 6
    echo "Rosdep update"
    tput sgr0
    rosdep update

    # Environment Setup - Don't add /opt/ros/NEW_ROS_DISTRO/setup.bash if it's already in bashrc
    tput setaf 6
    echo "Environment Setup"
    tput sgr0
    grep -q -F "source /opt/ros/$NEW_ROS_DISTRO/setup.bash" $HOME/.bashrc || echo "source /opt/ros/$NEW_ROS_DISTRO/setup.bash" >> $HOME/.bashrc
    
    tput setaf 6
    echo "Re run $USER bashrc in $HOME"
    tput sgr0
    source $HOME/.bashrc
    
    # Install rosinstall
    tput setaf 6
    echo "Install python-rosinstall"
    tput sgr0
    sudo apt-get install python-rosinstall -y
}

install_workspace()
{
    if [ ! -z ${NEW_ROS_WS+x} ] ; then
        # Load sources
        tput setaf 6
        echo "Load ROS sources"
        tput sgr0
        source /opt/ros/$NEW_ROS_DISTRO/setup.bash
        # Build default dir location
        local DEFAULTDIR=$HOME/$NEW_ROS_WS
        if [ ! -e "$DEFAULTDIR" ] ; then
            tput setaf 6
            echo "Creating Catkin Workspace: $DEFAULTDIR"
            tput sgr0
            mkdir -p "$DEFAULTDIR"/src
            # store position
            local LOCAL_FOLDER=$(pwd)
            # Move in jetson folder
            cd "$DEFAULTDIR"/
            # Launch catkin_make
            catkin_make
            # Go back in stored position
            cd $LOCAL_FOLDER
            # Load sources
            tput setaf 6
            echo "Load sources in .bashrc"
            tput sgr0
            grep -q -F "source $DEFAULTDIR/devel/setup.bash" $HOME/.bashrc || echo "source $DEFAULTDIR/devel/setup.bash" >> $HOME/.bashrc
        else
            tput setaf 1
            echo "Folder $DEFAULTDIR already exists; no action!"
            tput sgr0
        fi
    else
        echo "Any NEW_ROS_WS is setted"
    fi
}

script_run()
{
    if [ ! -z ${NEW_ROS_DISTRO+x} ]
    then
        tput setaf 6
        echo "Install ROS $NEW_ROS_DISTRO"
        tput sgr0
        if [ -z ${ROS_DISTRO+x} ]
        then
            # Launch ROS installer
            install_ros
        else
            if [ $NEW_ROS_DISTRO == $ROS_DISTRO ]
            then
                tput setaf 2
                echo "Same ROS $NEW_ROS_DISTRO is installed"
                tput sgr0
                if [ ! -z ${NEW_WORKSPACE+x} ] ; then
                    if [ $NEW_WORKSPACE == "1" ] ; then
                        # Launch New workspace installer
                        install_workspace
                    fi
                fi
            else
                tput setaf 1
                echo "Another ROS Distro is installed: $ROS_DISTRO"
                tput sgr0
            fi
        fi
    else
        tput setaf 1
        echo "Any ROS_DISTRO is selected"
        tput sgr0
    fi
}

script_save()
{
    if [ ! -z ${NEW_ROS_DISTRO+x} ]
    then
        echo "NEW_ROS_DISTRO=\"$NEW_ROS_DISTRO\"" >> $1
        echo "NEW_WORKSPACE=\"$NEW_WORKSPACE\"" >> $1
        echo "NEW_ROS_WS=\"$NEW_ROS_WS\"" >> $1
        echo "Saved ROS parameters"
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
    local NEW_WORKSPACE_TMP_VALUE
    NEW_WORKSPACE_TMP_VALUE=$(whiptail --title "$MODULE_NAME" --radiolist \
    "Do you want install the workspace?" 15 60 2 \
    "YES" "Install the workspace" $(ros_load_check "YES" $NEW_WORKSPACE) \
    "NO" "Skipp installation" $(ros_load_check "NO" $NEW_WORKSPACE) 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        NEW_WORKSPACE=$(ros_get_check $NEW_WORKSPACE_TMP_VALUE)
    fi
    
}

set_distro()
{
    if [ -z ${NEW_ROS_DISTRO+x} ]
    then
        # Write distribution
        NEW_ROS_DISTRO="kinetic"
    fi
    
    local ROS_DISTRO_TMP_VALUE
    ROS_DISTRO_TMP_VALUE=$(whiptail --title "$MODULE_NAME - Set distribution" --radiolist \
    "Set ROS distribution" 15 60 2 \
    "kinetic" "Install the workspace" $(ros_load_equal "kinetic" $NEW_ROS_DISTRO) \
    "lunar" "Skipp installation" $(ros_load_equal "lunar" $NEW_ROS_DISTRO) 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new distribution
        NEW_ROS_DISTRO=$ROS_DISTRO_TMP_VALUE
    fi
}

set_workspace()
{
    if [ -z ${NEW_ROS_WS+x} ]
    then
        # Write default workspace
        NEW_ROS_WS="catkin_ws"
    fi
    
    local NEW_ROS_WS_TMP_VALUE
    NEW_ROS_WS_TMP_VALUE=$(whiptail --inputbox "$MODULE_NAME - Set ROS workspace" 8 78 $NEW_ROS_WS --title "Set ROS workspace" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new workspace
        NEW_ROS_WS=$NEW_ROS_WS_TMP_VALUE
    fi
}
