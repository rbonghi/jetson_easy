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

title_header()
{
    tput cup 11 17
    # Set reverse video mode
    tput rev
    echo ${1^^} | sed -e 's/\(.\)/\1 /g'
    tput sgr0
    
    #put message in middle of screen
    tput cup 13 0
}

system_information()
{
    title_header "System-Information"
    
    tput setaf 2
    echo "  User: $USER"
    echo "  Hostname: $HOSTNAME"
    echo ""
    echo "  System information:"
    echo "   - OS: $DISTRIB_DESCRIPTION - $DISTRIB_CODENAME"
    echo "   - Architecture: $OS_ARCHITECTURE"
    echo "   - Kernel: $OS_KERNEL"
    echo ""
    echo "  NVIDIA embedded information:"
    echo "   - Board: $JETSON_DESCRIPTION"
    echo "   - Jetpack $JETSON_JETPACK - L4T: $JETSON_L4T"
    echo "   - CUDA: $CUDA_VERSION"
    echo ""
    tput sgr0
}

installation_setup()
{
    title_header "Start-Jetson Easy"

    tput setaf 4
    echo "  Installing order script"
    echo "   1 Update & Distribution upgrade & Upgrade"
    echo "   2 Install Jetson performance service"
    echo "   3 Set hostname"
    echo "   4 Setup user and email git"
    echo "   5 Install ROS"
    echo "   6 Install USB and ACM driver"
    tput sgr0
}
"Start Jetson easy"
run_script()
{
    # ------------------------------------
    # - update & dist-upgrade & upgrade

    sudo apt-get update
    echo -e $TEXT_YELLOW
    echo 'APT update finished...'
    echo -e $TEXT_RESET

    # Automatically upgrade all packages
    sudo apt-get -y dist-upgrade
    echo -e $TEXT_YELLOW
    echo 'APT distributive upgrade finished...'
    echo -e $TEXT_RESET

    # Automatically upgrade all packages
    sudo apt-get -y upgrade
    echo -e $TEXT_YELLOW
    echo 'APT upgrade finished...'
    echo -e $TEXT_RESET

    # Automatically remove packages
    sudo apt-get -y autoremove
    echo -e $TEXT_YELLOW
    echo 'APT auto remove finished...'
    echo -e $TEXT_RESET
}

tput setb 3 #Green in xterm and brown in linux terminal
#loop around gathering input until QUIT is more than 0
QUIT=0
# Start menu
SEL=1

while [ $QUIT -lt 1 ]
do

    tput clear

    # Write Header
    tput setaf 3
    echo ""
    echo "    Biddibi Boddibi Boo - NVIDIA Jetson easy setup script"
    echo "    Raffaello Bonghi - raffaello@rnext.it"
    tput sgr0
    echo ""
    echo "  MENU"
    echo "  1 .. System Information"
    echo "  2 .. Load scripts"
    echo "  3 .. Start Jetson easy"
    echo "  4 .. QUIT"
    tput bold
    echo "  Select item: "
    tput sgr0


    #Delete from cursor to end of line
    tput el
    case $SEL in
        1) system_information ;;
        3) installation_setup ;;
        *) title_header "Test"
           echo "You selected $SEL";;
    esac

    #Move cursor to after select message
    tput cup 9 15
    #Delete from cursor to end of line
    tput el
    read SEL
    if [ ${#SEL} -lt 1 ]
        then
            continue
    fi
    if [ $SEL -eq 4 ]
        then
            QUIT=1
            continue
    fi
   
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

