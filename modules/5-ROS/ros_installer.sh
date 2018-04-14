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

ros_install()
{
    # Automatically update all packages
    tput setaf 6
    echo 'APT Set repository [universe, multiverse, restricted]'
    tput sgr0
    
    # Configure repositories
    sudo apt-add-repository universe
    sudo apt-add-repository multiverse
    sudo apt-add-repository restricted

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
    echo "Install ROS ros-$ROS_NEW_DISTRO-ros-base"
    tput sgr0
    sudo apt-get install ros-$ROS_NEW_DISTRO-ros-base -y

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
    grep -q -F "source /opt/ros/$ROS_NEW_DISTRO/setup.bash" $HOME/.bashrc || echo "source /opt/ros/$ROS_NEW_DISTRO/setup.bash" >> $HOME/.bashrc
    
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

ros_install_workspace()
{
    if [ ! -z ${ROS_NEW_WS+x} ] ; then
        # Build default dir location
        local DEFAULTDIR=$HOME/$NEW_ROS_WS
        
        if [ ! -e "$DEFAULTDIR" ] ; then
            tput setaf 6
            echo "Creating Catkin Workspace: $DEFAULTDIR"
            tput sgr0
            mkdir -p "$DEFAULTDIR"/src
            
            tput setaf 6
            echo "Load ROS environment"
            tput sgr0
            source /opt/ros/$ROS_NEW_DISTRO/setup.bash
            
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
            
            tput setaf 6
            echo "Re run $USER bashrc in $HOME"
            tput sgr0
            source $HOME/.bashrc
        else
            tput setaf 1
            echo "Folder $NEW_ROS_WS already exists!"
            tput sgr0
        fi
    else
        echo "Any NEW_ROS_WS is setted"
    fi
}

