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
    if [ -z ${DEBUG+x} ] 
    then
        echo ""
    else
        tput setaf 1
        tput bold
        echo "DEBUG MODE"
        tput sgr0
    fi
    tput setaf 3
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

print_isSetup()
{
    tput bold
    if [ $CONFIG_SAVED -eq 1 ] ;
    then
        tput setaf 1
        echo "  Configuration SAVED!"
        CONFIG_SAVED=0
    else
        if [ -f setup.txt ]
        then
            echo "  Loaded configuration from setup.txt"
        else
            echo "  Loaded default configuration"
        fi
    fi
    tput sgr0
}

system_information()
{    
    # Load which type of configuration is loaded
    tput setaf 2
    print_isSetup
    
    tput setaf 2
    echo "  User: $LOCAL_USER"
    echo "  Hostname: $HOSTNAME"
    echo ""
    echo "  System:"
    echo "   - OS: $DISTRIB_DESCRIPTION - $DISTRIB_CODENAME"
    echo "   - Architecture: $OS_ARCHITECTURE"
    echo "   - Kernel: $OS_KERNEL"
    echo ""
    tput sgr0
    
    if [ -z ${JETSON_DESCRIPTION+x} ] ; 
    then 
        tput setaf 1
        tput bold
        echo "  This is not a Jetson Board"
        echo "  Please copy this repository in your Jetson board"
        tput sgr0
    else
        tput setaf 2
        echo "  NVIDIA embedded:"
        echo "   - Board: $JETSON_DESCRIPTION"
        echo "   - Jetpack $JETSON_JETPACK [L4T $JETSON_L4T]"
        echo "   - CUDA: $JETSON_CUDA"
        tput sgr0
    fi
}

system_menu()
{    
    echo ""
    tput bold
    echo "  MENU"
    tput sgr0
    
    # Add in menu the option to start the jetson easy only if is a Jetson board or is in debug mode
    if [ ! -z ${JETSON_DESCRIPTION+x} ] || [ ! -z ${DEBUG+x} ]; 
    then 
        echo "  [J] .. Start Jetson Easy"
        echo "  [Q] .. QUIT"
        
        read -r -p "  Select item: " SEL
        case "${SEL^^}" in
            "J") SEL=1
                 continue ;;
            "Q") QUIT=1
                continue ;;
        esac
    else
        tput bold
        read -n 1 -s -r -p "  Press any key to CLOSE"
        tput sgr0
        # Close script
        QUIT=1
        continue
    fi
}

