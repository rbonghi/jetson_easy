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

TEXT_RESET='\e[0m'
TEXT_GREEN='\e[0;32m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'

# Load all script in folder
for file in include/* ; do
  if [ -f "$file" ] ; then
    source "$file"
  fi
done

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
source jetson/jetson_release.sh

# Load cuda version
CUDA_VERSION=$(cat /usr/local/cuda/version.txt | sed 's/\CUDA Version //g')

#loop around gathering input until QUIT is more than 0
QUIT=0
# Start menu
SEL=0

# Load setup
load_modules

while [ $QUIT -lt 1 ]
do
    # Clear shell
    tput clear
    
    #Delete from cursor to end of line
    #tput el
    case $SEL in
        1)  # Load header
            title_header "Start-Jetson Easy"
            # Load page
            installation_setup ;;
        2)  # Load header
            title_header "Jetson Easy-Installing"
            # Load page
            installing_page ;;
        3)  # Load header
            title_header "Jetson Easy-Recap"
            # Load page
            ending_page ;;
        *)  # Load header
            title_header "System-Information"
            # Load page
            system_information
            system_menu ;;
    esac

done

#reset the screen
#Find out if this is a "linux" virtual terminal
if [ $TERM ~ "linux" ]
then
     tput setb 0 #reset background to black
fi

tput reset
tput clear
tput rc

if [ -f /var/run/reboot-required ]; then
    echo -e $TEXT_RED_B
    echo 'Reboot required!'
    echo -e $TEXT_RESET
fi

