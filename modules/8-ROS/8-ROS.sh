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

ros_wstool_string()
{
    local regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    if [[ $ROS_WSTOOL =~ $regex ]] ; then
    
        # Remove .rosinstall if written
        local string=$(echo $(basename $ROS_WSTOOL) | cut -f1 -d ".")
        # Is a weblink
        echo "weblink $(basename $string)"
    else
        # Remove .rosinstall if written
        local string=$(echo $ROS_WSTOOL | cut -f1 -d ".")
        # Load from file
        echo "file in config/$string"
    fi
}

##################################################

script_list()
{
    if [ ! -z ${ROS_DISTRO+x} ] ; then
        echo "(*) ROS:"
        echo "    - Distro: $ROS_DISTRO"
        echo "    - ROS_MASTER_URI: $ROS_MASTER_URI"
        if [ ! -z ${ROS_HOSTNAME+x} ] ; then
            echo "    - ROS_HOSTNAME: $ROS_HOSTNAME"
        fi
    else
        echo "(*) ROS Not installed!"
    fi
}

################# RUN ############################

script_run()
{
    # Load home reference
    local HOME_FOLDER=$1
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
            ros_install
            tput setaf 6
            echo "Load ROS environment"
            tput sgr0
            source /opt/ros/$ROS_NEW_DISTRO/setup.bash
        else            
            if [ $ROS_NEW_DISTRO == $ROS_DISTRO ] ; then
                tput setaf 3
                echo "ROS $ROS_DISTRO is already installed"
                tput sgr0
            else
                tput setaf 1
                echo "ROS $ROS_NEW_DISTRO cannot installed. $ROS_DISTRO is already installed"
                tput sgr0
            fi
        fi
    else
        tput setaf 1
        echo "Any ROS_DISTRO is selected"
        tput sgr0
    fi
    
    # ROS workspace installer
    if [ ! -z ${ROS_SET_WORKSPACE+x} ] && [ $ROS_SET_WORKSPACE == "YES" ] ; then
        # Load default value
        if [ -z ${ROS_NAME_WS+x} ] || [ -z $ROS_NAME_WS ] ; then
            ROS_NAME_WS="catkin_ws"
        fi
        # Check if the folrder exist
        if [ ! -d $HOME/$ROS_NAME_WS ] ; then
            tput setaf 6
            echo "Build new ROS workspace $ROS_NAME_WS"
            tput sgr0
            
            # Launch New workspace installer
            ros_install_workspace $ROS_NAME_WS $ROS_DISTRO
        else
            tput setaf 1
            echo "Folder $ROS_NAME_WS exist! Stop!"
            tput sgr0
        fi
        
        if [ ! -z $ROS_WSTOOL ] ; then
            
            local regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
            local path
            
            tput setaf 6
            echo "Import all ROS workspace from $ROS_WSTOOL"
            tput sgr0
                                   
            if [[ $ROS_WSTOOL =~ $regex ]] ; then
                # the path is the same of loaded
                path=$ROS_WSTOOL
            else
                # load from config
                path="$HOME_FOLDER/config/$ROS_WSTOOL"
            fi
            
            tput setaf 6
            echo "Reference path is $path"
            tput sgr0
            
            ./ros_wstool.sh -w $ROS_NAME_WS -r $path
        fi
    fi
    
    # Add in ROS_MASTER_URI and ROS_HOSTNAME in bashrc
    ros_add_inbashrc
}

##################################################

script_load_default()
{
    # Write distribution
    #if [ -z ${ROS_NEW_DISTRO+x} ] ; then
    #    ROS_NEW_DISTRO="kinetic"
    #fi
    
    # Set default Distribution
    if [ -z ${ROS_DISTRO_TYPE+x} ] ; then
        ROS_DISTRO_TYPE="ros-base"
    fi
    
    # Write default workspace
    if [ -z ${ROS_NAME_WS+x} ] ; then
        ROS_NAME_WS="catkin_ws"
    fi
    
    # Set is install workspace
    if [ -z ${ROS_SET_WORKSPACE+x} ] ; then
        ROS_SET_WORKSPACE="NO"
    fi
    
    # Set dafault reference wstool file
    if [ -z ${ROS_WSTOOL+x} ] ; then
        ROS_WSTOOL=""
    fi
    
    # Write new ROS_NEW_HOSTNAME
    ROS_SET_HOSTNAME="NO"
    
    # Write new ROS_NEW_MASTER_URI
    if [ ! -z ${ROS_MASTER_URI+x} ] ; then
        ROS_NEW_MASTER_URI=$ROS_MASTER_URI
    else
        ROS_NEW_MASTER_URI="http://localhost:11311"
    fi
}

script_save()
{
    # ROS Distribution name
    if [ ! -z ${ROS_NEW_DISTRO+x} ] && [ ! -z $ROS_NEW_DISTRO ] ; then
        echo "ROS_NEW_DISTRO=\"$ROS_NEW_DISTRO\"" >> $1
    fi
    
    if [ ! -z ${ROS_DISTRO_TYPE+x} ] && [ $ROS_DISTRO_TYPE != "base" ] ; then
        echo "ROS_DISTRO_TYPE=\"$ROS_DISTRO_TYPE\"" >> $1
    fi
    
    # ROS name workspace
    if [ ! -z ${ROS_NAME_WS+x} ] && [ $ROS_NAME_WS != "catkin_ws" ] ; then
        echo "ROS_NAME_WS=\"$ROS_NAME_WS\"" >> $1
    fi
    
    # ROS set workspace
    if [ ! -z ${ROS_SET_WORKSPACE+x} ] && [ $ROS_SET_WORKSPACE != "NO" ] ; then
        echo "ROS_SET_WORKSPACE=\"$ROS_SET_WORKSPACE\"" >> $1
    fi
    
    if [ ! -z $ROS_WSTOOL ] ; then
        echo "ROS_WSTOOL=\"$ROS_WSTOOL\"" >> $1
    fi
    
    # Write new ROS_NEW_HOSTNAME
    if [ ! -z ${ROS_SET_HOSTNAME+x} ] && [ $ROS_SET_HOSTNAME != "NO" ] ; then
        echo "ROS_SET_HOSTNAME=\"$ROS_SET_HOSTNAME\"" >> $1
    fi
    
    # Write new ROS_NEW_MASTER_URI
    if [ ! -z ${ROS_NEW_MASTER_URI+x} ] && [ $ROS_NEW_MASTER_URI != "http://localhost:11311" ] && [ $ROS_NEW_MASTER_URI != $ROS_MASTER_URI ] ; then
        echo "ROS_NEW_MASTER_URI=\"$ROS_NEW_MASTER_URI\"" >> $1
    fi
}

script_info()
{
    if [ $ROS_SET_WORKSPACE == "YES" ] ; then
        echo " - New workspace: $ROS_NAME_WS"
    fi

    if [ $ROS_SET_HOSTNAME == "YES" ] ; then
        ROS_NEW_MASTER_URI="http://$HOSTNAME.local:11311"
        local check_hostname=$(ros_check_isinfile $HOME/.bashrc "export ROS_HOSTNAME=\"$HOSTNAME\"")
        if [ $check_hostname == "NO" ] ; then
            echo " - Add in .bashrc: ROS_HOSTNAME=$HOSTNAME"
        fi
    fi
    
    if [ $ROS_NEW_MASTER_URI != "http://localhost:11311" ] && [ ! -z ${ROS_MASTER_URI+x} ] && [ $ROS_NEW_MASTER_URI != $ROS_MASTER_URI ] ; then
        echo " - Add in .bashrc: ROS_MASTER_URI=\"$ROS_NEW_MASTER_URI\""
    fi
    
    if [ ! -z $ROS_WSTOOL ] ; then
        # Add information about data
        echo " - Add wstool from $(ros_wstool_string)"
    fi
}

#### COMMON FUNCTIONS ####

ros_check_isinfile()
{
    local FILE=$1
    local PARAMETER=$2
    local find_data=$(find $FILE -type f -print | xargs grep "$PARAMETER")
        
    if [ ! -z "$find_data" ] && [ $find_data == "$PARAMETER" ] ; then
        echo "YES"
    else
        echo "NO"
    fi
}

ros_load_equal()
{
    if [ ! -z ${2+x} ] && [ $1 == $2 ] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

ros_load_check()
{
    if [ ! -z ${1+x} ] ; then
        if [ $1 == "YES" ] ; then
            if [ ! -z ${2+x} ] && [ $2 == "YES" ] ; then
                echo "ON"
            else
                echo "OFF"
            fi
        else
            if [ ! -z ${2+x} ] && [ $2 == "NO" ] ; then
                echo "ON"
            else
                echo "OFF"
            fi
        fi
    else
        echo "OFF"
    fi
}

#### SET DISTRIBUTION ####

ros_set_distro()
{
    local ros_new_distro_temp
    ros_new_distro_temp=$(whiptail --title "Set distribution" --radiolist \
    "Set ROS distribution" 15 60 2 \
    "kinetic" "Install the workspace" $(ros_load_equal "kinetic" $ROS_NEW_DISTRO) \
    "lunar" "Skipp installation" $(ros_load_equal "lunar" $ROS_NEW_DISTRO) 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new distribution
        ROS_NEW_DISTRO=$ros_new_distro_temp
    fi
}

#### SET ROS DISTRO TYPE ####

ros_set_distro_type()
{
    local ros_distro_type_temp
    ros_distro_type_temp=$(whiptail --title "Set distribution" --radiolist \
    "Select the ROS distribution" 15 70 3 \
    "ros-base"     "ROS Base is the smallest version of ROS" $(ros_load_equal "ros-base" $ROS_DISTRO_TYPE) \
    "desktop"      "ROS with GUI nodes" $(ros_load_equal "desktop" $ROS_DISTRO_TYPE) \
    "desktop-full" "ROS with GUI and Gazebo" $(ros_load_equal "full" $ROS_DISTRO_TYPE) 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new distribution
        ROS_DISTRO_TYPE=$ros_distro_type_temp
    fi
}

#### SET WORKSPACE ####

ros_set_workspace()
{
    local ros_set_workspace_temp
    ros_set_workspace_temp=$(whiptail --title "$MODULE_NAME" --radiolist \
    "Do you want install the workspace?" 15 60 2 \
    "YES" "Install the workspace" $(ros_load_check "YES" $ROS_SET_WORKSPACE) \
    "NO" "Skipp installation" $(ros_load_check "NO" $ROS_SET_WORKSPACE) 3>&1 1>&2 2>&3)
    
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        ROS_SET_WORKSPACE=$ros_set_workspace_temp
    fi
}

ros_name_workspace()
{
    local ros_name_workspace_temp
    ros_name_workspace_temp=$(whiptail --inputbox "Set ROS workspace" 8 78 $ROS_NAME_WS --title "Set ROS workspace" 3>&1 1>&2 2>&3)
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the new workspace
        ROS_NAME_WS=$ros_name_workspace_temp
    fi
}

ros_wstool()
{
    local ros_wstool_temp
    ros_wstool_temp=$(whiptail --inputbox "Set reference wstool" 8 78 $ROS_WSTOOL --title "Set reference wstool" 3>&1 1>&2 2>&3)
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write the wstool file reference
        ROS_WSTOOL=$ros_wstool_temp
    fi
}

#### SET ROS_HOSTNAME ####

ros_set_hostname()
{
    local ros_set_hostname_temp
    ros_set_hostname_temp=$(whiptail --title "$MODULE_NAME - Set Hostname variable" --radiolist \
    "Do you want use set hostname variable?" 15 60 2 \
    "YES" "Use same hostname" $(ros_load_check "YES" $ROS_SET_HOSTNAME) \
    "NO" "Manual edit" $(ros_load_check "NO" $ROS_SET_HOSTNAME) 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        ROS_SET_HOSTNAME=$ros_set_hostname_temp
    fi
}

#### SET ROS_MASTER_URI ####

ros_set_master_uri()
{
    local ros_set_master_uri_temp
    ros_set_master_uri_temp=$(whiptail --inputbox "Set ROS_MASTER_URI" 8 78 $ROS_NEW_MASTER_URI --title "Set ROS_MASTER_URI" 3>&1 1>&2 2>&3)
    
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write new ROS_MASTER_URI
        ROS_NEW_MASTER_URI=$ros_set_master_uri_temp
    fi
}

#### LOAD MODULE VARIABLES ####

ros_load_version()
{
    if [ -z ${1+x} ] ; then
        # Check if exist an option to write
        if [ -z ${2+x} ] ; then
            echo " $2"
        else
            echo ""
        fi
    else
        echo "- $1"
    fi
}

ros_name_module()
{
    if [ ! -z ${ROS_NEW_DISTRO+x} ] ; then
        echo "- $ROS_NEW_DISTRO - $ROS_DISTRO_TYPE"
    fi
}

# Default variables load
MODULE_NAME="Install ROS $(ros_name_module)"
MODULE_DESCRIPTION="ROS - This module install the release of ROS, build a workspace, set a new hostname and set a new master uri"
MODULE_DEFAULT=0

ros_is_check()
{
    if [ ! -z ${1+x} ] && [ $1 == "YES" ] ; then
        echo "X"
    else
        echo " "
    fi
}

ros_string_wstool()
{
    if [ ! -z $ROS_WSTOOL ] ; then
        echo "[$(ros_wstool_string)]"
    fi
}

# SUB MENU Module
## Name distribution
MODULE_SUBMENU=("ROS disto $(ros_load_version $ROS_NEW_DISTRO 'SELECT DISTRO'):ros_set_distro" )
## Name type
MODULE_SUBMENU+=("Install ROS $(ros_load_version $ROS_DISTRO_TYPE):ros_set_distro_type")
## Name workspace
MODULE_SUBMENU+=("[$(ros_is_check $ROS_SET_WORKSPACE)] Install workspace $(ros_load_version $ROS_NAME_WS):ros_set_workspace")
# Add name ROS option
if [ ! -z ${ROS_SET_WORKSPACE+x} ] && [ $ROS_SET_WORKSPACE == "YES" ] ; then
    MODULE_SUBMENU+=(" - Set name workspace:ros_name_workspace")
    MODULE_SUBMENU+=(" - Set wstool $(ros_string_wstool):ros_wstool")
fi 
MODULE_SUBMENU+=("[$(ros_is_check $ROS_SET_HOSTNAME)] Set ROS_HOSTNAME:ros_set_hostname")
# Enable name ROS option
if [ ! -z ${ROS_SET_HOSTNAME+x} ] && [ $ROS_SET_HOSTNAME == "NO" ] ; then
    MODULE_SUBMENU+=(" - Set ROS_MASTER_URI:ros_set_master_uri")
fi 

