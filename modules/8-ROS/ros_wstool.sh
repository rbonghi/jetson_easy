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

# wstool installer

# Reference https://stackoverflow.com/questions/3183444/check-for-valid-link-url
wstool_load_rosinstall()
{
    local string=$1
    local regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    
    if [[ $string =~ $regex ]] ; then
        # Download $string
        wget -N $string
        # Return name file
        echo $(basename $string)
        return 0
    else
        # Remove .rosinstall if written
        string=$(echo $string | cut -f1 -d ".")
        # Check if exist the rosinstall file
        if [ -f $string.rosinstall ] ; then
            # String is a file
            echo "$string.rosinstall"
            return 0
        else
            echo "$string.rosinstall"
            return 1
        fi
    fi
}

# http://wiki.ros.org/wstool
wstool_install()
{
    local WS_FOLDER=$1
    local DEFAULTDIR=$HOME/$WS_FOLDER
    local REFERENCE_ROSINSTALL_FILE=$2
 
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    tput setaf 6
    echo "Install wstool"
    tput sgr0
    
    sudo apt install python-wstool
    
    # Download and check rosinstall file
    local PATH_FILE
    PATH_FILE=$(wstool_load_rosinstall $REFERENCE_ROSINSTALL_FILE)
    
    if [ $? = 0 ] ; then
        
        tput setaf 6
        echo "Initialization wstool in $WS_FOLDER with $PATH_FILE"
        tput sgr0
        
        cd $DEFAULTDIR
        wstool init src $PATH_FILE
        
        tput setaf 6
        echo "Download all required packages"
        tput sgr0
        rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
        
        tput setaf 6
        echo "Catkin make ROS workspace $WS_FOLDER"
        tput sgr0
        
        catkin_make
    
    else
        tput setaf 1
        echo "File/Link \"$PATH_FILE\" does not exist!"
        tput sgr0
    fi
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

usage()
{
	if [ "$1" != "" ]; then
    	tput setaf 1
		echo "$1"
		tput sgr0
	fi

    echo "usage: ros_wstool [[-w workspace ] | [-d rosinstall ] | [-h]]"
    echo "   -h|--help      | This help"
    echo "   -w             | Load workspace folder"
    echo "   -r             | Load rosinstall configuration"
}

main()
{
    #defaut configuration
    local ROSINSTALL="robot"
    local ROSWS="catkin_ws"
	
    while [ "$1" != "" ]; do
        case $1 in
            -w) 
                ROSWS=$2
                shift 1
                ;;
            -r) 
                ROSINSTALL=$2
                shift 1
                ;;
            -h|--help) usage
                       exit
                       ;;
		    *)  usage "Unknown option: $1"
		        exit 1
			    ;;
        esac
        shift
    done
    
    # Launch wstool_install
    wstool_install $ROSWS $ROSINSTALL
}

main $@
exit 0

