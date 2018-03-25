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

# To Enable the debug mode
if [ -f DEBUG ]; then
    DEBUG=1
fi

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
source jetson/jetson_variables.sh

# --------------------------------
# MAIN
# --------------------------------

usage()
{
    echo "Bibbibi Boddibi Boo is an automatic install for different type of modules."
    echo "Usage:"
    echo "$0 [options]"
    echo "options,"
    echo "   -h|--help | This help"
    echo "   -s        | Launch the system in silent mode (Without GUI)"
}

loop_gui()
{
    # Load user interface
    source include/modules.sh
    # Load user interface
    source include/gui.sh
    
    # Load all modules
    modules_load
    # Load GUI menu loop
	menu_loop
}

silent_mode()
{
    # Load user interface
    source include/modules.sh

    # Load all modules
    modules_load

    # Load user interface
    source include/gui.sh
    
    # All modules are in MODULES_LIST
    echo "Module loaded:"
    echo $MODULES_LIST
    
    # Run installer script
    modules_run
    
    if [ $(modules_require_reboot) == "1" ]
    then
        echo "Reboot required!"
        sudo reboot
    fi
}

main()
{
	case "$1" in
	    -s)
	        # Launch the system in silent mode (Without GUI)
	        silent_mode
	        ;;
        -h|--help)
            # Load help
			usage
			;;
		*)
		    # Load GUI menu loop
			loop_gui
			;;
	esac
}

main $@
exit 0

