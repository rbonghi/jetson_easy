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

convert_string()
{
    # Load name
    if [ $1 -eq 1 ]
    then
        echo "X"
    else
        echo " "
    fi
}

# Load hte installation page script
installation_setup()
{
    # Load which type of configuration is loaded
    tput setaf 4
    print_isSetup
    
    tput setaf 4
    echo "  Legend: [X]= Run [ ]= Skip"
    echo ""
    echo "  Installing order script"
    # Load all modules availables 
    print_all_modules
    echo "  TODO Setup user and email git"
    echo "  TODO Install USB and ACM driver"
    tput sgr0
    echo ""
    tput bold    
    echo "  MENU"
    tput sgr0
    echo "  [I] .. System Information"
    echo "  [M] .. Modify"
    echo "  [S] .. Save configuration in setup.txt"
    echo "  [R] .. RUN"
    echo "  [Q] .. QUIT"
    read -r -p "  Select item: " INSTALL_SEL    
    case "${INSTALL_SEL^^}" in
        "I")  # Go In system information page
            SEL=0
            continue ;;
        "Q")  # Close the script
            QUIT=1
            continue ;;
        "M")  # Modify script
            modify_list_modules 10 6
            continue ;;
        "S") # Save setup
             save_setup
             continue ;;
        "R")  # Launch Installing script
            SEL=2
            continue ;;
        # Otherwise skip
        *)  continue ;;
    esac
}

# Installing page
installing_page()
{
    # Execute in order all scripts
    IFS=':' read -ra ADDR <<< "$LOAD_SCRIPT"
    for i in "${ADDR[@]}"; do
        # process "$i"
        source "$i"
        # Write the module name
        echo $MODULE_NAME
        # Execute run script
        run_script
    done
    
    echo ""
    # Wait before to close
    #read -p "Press enter to continue"
    read -n 1 -s -r -p "Press any key to continue"
    SEL=3
    continue
}

# Installing page
ending_page()
{

    #system_information
    
    tput setaf 6
    echo "  Module installed:"
    print_done_modules
    tput sgr0
    
    if [ -f /var/run/reboot-required ]; then
        tput setaf 1
        tput bold
        echo "    Reboot required!"
        echo ""
        tput sgr0
    fi
    
    # Wait before to close
    #read -p "Press enter to continue"
    tput bold
    read -n 1 -s -r -p "  Press any key to CLOSE"
    tput sgr0
    # Close script
    QUIT=1
    continue
}
