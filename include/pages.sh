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
    echo "  System:"
    echo "   - OS: $DISTRIB_DESCRIPTION - $DISTRIB_CODENAME"
    echo "   - Architecture: $OS_ARCHITECTURE"
    echo "   - Kernel: $OS_KERNEL"
    echo ""
    echo "  NVIDIA embedded:"
    echo "   - Board: $JETSON_DESCRIPTION"
    echo "   - Jetpack $JETSON_JETPACK - L4T: $JETSON_L4T"
    echo "   - CUDA: $CUDA_VERSION"
    tput sgr0
}

system_menu()
{    
    echo ""
    tput bold
    echo "  MENU"
    tput sgr0
    echo "  [S] .. Start Jetson Easy"
    echo "  [Q] .. QUIT"
    
    read -r -p "  Select item: " SEL
    case "${SEL^^}" in
        "S") SEL=1 ;;
        "Q") QUIT=1
            continue ;;
    esac
}

