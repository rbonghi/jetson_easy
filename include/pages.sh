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

title_header()
{
    # Write Header
    tput setaf 3
    echo ""
    echo "    Biddibi Boddibi Boo - NVIDIA Jetson Easy setup script"
    echo "    Raffaello Bonghi - raffaello@rnext.it"
    tput sgr0
    
    tput cup 4 17
    # Set reverse video mode
    tput rev
    echo ${1^^} | sed -e 's/\(.\)/\1 /g'
    tput sgr0
    
    #put message in middle of screen
    tput cup 6 0
}

system_information()
{    
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
    tput sgr0
    
    echo ""
    tput bold
    echo "  MENU"
    tput sgr0
    echo "  1 .. Start Jetson Easy"
    echo "  2 .. QUIT"
    
    read -r -p "  Select item: " SEL
    if [ ${#SEL} -lt 1 ]
    then
        continue
    fi
    if [ $SEL -eq 2 ]
        then
            QUIT=1
            continue
    fi
}

installation_setup()
{
    tput setaf 4
    echo "  Legend: \"X\"= Run \" \"= Skip"
    echo ""
    echo "  Installing order script"
    echo "   1. [ ] Update & Distribution upgrade & Upgrade"
    echo "   2. [ ] Install Jetson performance service"
    echo "   3. [ ] Set hostname"
    echo "   4. [ ] Setup user and email git"
    echo "   5. [ ] Install ROS"
    echo "   6. [ ] Install USB and ACM driver"
    tput sgr0
    
    echo ""
    tput bold
    echo "  MENU"
    tput sgr0
    echo "  1 .. System Information"
    echo "  2 .. QUIT"
    echo "  3 .. Modify"
    echo "  4 .. START"
    read -r -p "  Select item: " INSTALL_SEL
    if [ ${#INSTALL_SEL} -lt 1 ]
    then
        continue
    fi
    case $INSTALL_SEL in
        1)  # Go In system information page
            SEL=0
            continue ;;
        2)  # Close the script
            QUIT=1
            continue ;;
        4)  # Launch Installing script
            SEL=2
            continue ;;
        # Otherwise skip
        *)  continue ;;
    esac
}

installing_page()
{
    echo "  Hellooo..."
    echo ""
    
    read -r -p "  Quit [2]" INSTALLING_SEL
    if [ ${#INSTALLING_SEL} -lt 1 ]
    then
        continue
    fi
    if [ $INSTALLING_SEL -eq 2 ]
        then
            QUIT=1
            continue
    fi
}
