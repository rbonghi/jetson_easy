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

# Load environment variables:
# - DISTRIB_ID
# - DISTRIB_RELEASE
# - DISTRIB_CODENAME
# - DISTRIB_DESCRIPTION
source /etc/lsb-release

# Load architecture
OS_ARCHITECTURE=$(uname -m)
OS_KERNEL=$(uname -r)

# Load environment variables:
# - JETSON_BOARD
# - JETSON_L4T (JETSON_L4T_RELEASE, JETSON_L4T_REVISION)
# - JETSON_DESCRIPTION
# - JETSON_CUDA
source jetson/jetson_variables

# Load common script filed
source include/common.sh
# Load user interface
source include/modules.sh
# Load remote sources
source include/remote.sh
        
# To Enable the debug mode
if [ -f DEBUG ]; then
    # Set in debug mode
    DEBUG=1
    # Load source as a file
    source DEBUG
    tput setaf 1
    echo "Load debug variables"
    tput sgr0
fi

# --------------------------------
# MAIN
# --------------------------------

usage()
{
	if [ "$1" != "" ]; then
    	tput setaf 1
		echo "$1"
		tput sgr0
	fi
	
    echo "Bibbibi Boddibi Boo is an automatic install for different type of modules."
    echo "Usage:"
    echo "$0 [options]"
    echo "options,"
    echo "   -h|--help      | This help"
    echo "   --nogui        | Launch the system in silent mode (Without GUI)"
    echo "   -q|--quiet     | If required, force automatically the reboot"
    echo "   -c [file]      | Load configuration file from other reference [file]"
    echo "   -m [user@host] | Remote connection with NVIDIA Jetson host"
    echo "   -p [passwd]    | Load password without any other request from the script"
}

loop_gui()
{
    # Load user interface
    source include/gui.sh

    # Load all modules
    modules_load
    
    if [ $MODULE_REMOTE == "1" ] ; then
        # Load remote gui interface sources
        source include/remote_gui.sh
        # Load remote menu
        menu_remote
    else
        # Set menu selection
        if [ $MODULE_IM_HOST == "1" ] ; then
            MENU_SELECTION=$1
        fi
        # Load GUI menu loop
	    menu_loop
    fi
}

no_gui()
{
    # Load all modules
    modules_load

    if [ $MODULE_REMOTE == "1" ] ; then

        if [ -z $MODULE_REMOTE_USER ] ; then
            echo "empty user"
            
            local USER_HOST=""
            echo "Write the user@remote for your board?: "
            read USER_HOST
            remote_get_user_host $USER_HOST
        fi
        
        if [ -z $MODULE_PASSWORD ] ; then
            echo "empty password"
            
            echo "What is the password?: "
            read -s MODULE_PASSWORD
        fi
        
        # Check connection
        local CONNECTION=$(remote_check_host)
        
        echo "Connection to ..."
        echo "User: $MODULE_REMOTE_USER"
        echo "Host: $MODULE_REMOTE_HOST"
        
        if [ $CONNECTION == "YES" ] ; then
            # Load system and connect
            remote_connect -s
        fi
    else
        # All modules are in MODULES_LIST
        echo "Module loaded:"
        echo $MODULES_LIST
        
	    if [ ! -z $MODULE_PASSWORD ] ; then
	        # Pass set
	        $(echo $MODULE_PASSWORD | sudo -S -i true)
	    fi
        
        # Run installer script
        echo "Module run:"
        modules_run
        
        if [ $(modules_require_reboot) == "1" ]
        then
            tput setaf 1
            echo "Reboot required!"
            tput sgr0

            if [ -z ${MODULE_REBOOT+x} ] ; then
                read -p "Do you want reboot? [Y/n]" -n 1 -r
                echo    # (optional) move to a new line
                if [[ $REPLY =~ ^[Yy]$ ]]
                then
                    echo "REBOOOT"
                    sudo reboot
                fi
            else
                echo "REBOOOT"
                sudo reboot
            fi
        fi
    fi
}

main()
{
    while [ -n "$1" ]; do
	    case "$1" in
	        -p) 
	            # Load password without any other request from the script
	            MODULE_PASSWORD="$2"
	            shift 1
	            ;;
	        -c)
	            # Load configuration file from other reference [file]
	            MODULES_CONFIG="$2"
	            shift 1
	            ;;
	        --nogui)
	            # Launch the system in silent mode (Without GUI)
	            NO_GUI=1
	            ;;
            -h|--help)
                # Load help
			    usage
			    exit 0
			    ;;
			-q|--quiet)
			    # If required, force automatically the reboot
			    MODULE_REBOOT=1
			    ;;
			-m) # Load user and HOST
			    remote_get_user_host "$2"
			    # Set anyway in Remote mode
			    MODULE_REMOTE=1
			    shift 1
			    ;;
			-x) # Internal option in remote mode
			    MODULE_IM_HOST=1
			    # Set the page to load
			    MENU_SELECTION="$2"
			    shift 1
			    ;;
		    *)
		        usage "Unknown option: $1"
		        exit 1
			    ;;
	    esac
		shift 1
	done
	
	local mytitle="Jetson Easy"
	
	# Check if the code run in NVIDIA Jetson or in remote
	if [ -z $JETSON_BOARD ] ; then
	    # Set in Remote mode
	    MODULE_REMOTE=1
	    mytitle="Jetson Easy - Remote connection"
		# check if is installed sshpass
		if ! dpkg-query -l sshpass > /dev/null; then
			tput setaf 1
			echo "Install sshpass..."
			tput sgr0
			sudo apt-get install sshpass
		fi
	else
	    mytitle="Jetson Easy on $USER@$HOSTNAME"
	fi
	
    # Set title shellbash
    echo -ne '\033]2;'$mytitle'\007'
	
	if [ ! -z $NO_GUI ] ; then
	    unset NO_GUI
        # Launch the system in silent mode (Without GUI)
        no_gui
	else
        # Load GUI menu loop
        loop_gui $MENU_SELECTION
	fi
}

main $@
exit 0

