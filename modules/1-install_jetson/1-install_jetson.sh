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

# Install all Jetson enviroments variables and performance service

MODULE_NAME="Install Jetson performance service"
MODULE_DESCRIPTION="Install jetson_release add variables and jetson_performance"
MODULE_DEFAULT=1

script_run()
{
    local JETSON_FOLDER="/etc/jetson_easy"
    local JETSON_BIN_FOLDER="/usr/local/bin"
    
    # Uninstall the service
    if service --status-all | grep -Fq 'jetson_performance'; then
        echo "Stop and uninstall the jetson performance script"
        sudo service jetson_performance uninstall
    fi

    if [ -d "$JETSON_FOLDER" ]; then
        # remove folder
        echo "Remove old folder"
        sudo rm -r $JETSON_FOLDER
    fi
    echo "Write Jetson folder in $JETSON_FOLDER ..."
    # Copy folder
    #sudo cp -r $(pwd)/jetson/ $JETSON_FOLDER
    
    # Write a new dir and copy scripts
    sudo mkdir $JETSON_FOLDER
    sudo cp $(pwd)/jetson/jetson_variables.sh "$JETSON_FOLDER/jetson_variables"
    sudo cp $(pwd)/jetson/jetson_performance.sh "$JETSON_FOLDER/jetson_performance.sh"
    
    echo "Load jetson_release script $JETSON_FOLDER ..."
    sudo cp $(pwd)/jetson/jetson_release.sh "$JETSON_BIN_FOLDER/jetson_release"
    
    # Add reference jetson_reference
    
    # Install Jetson perfomance service
    sudo $JETSON_FOLDER/jetson_performance.sh install
    
    # Set default configuration
    
    
    # END
    echo "... END INSTALL!"
}


