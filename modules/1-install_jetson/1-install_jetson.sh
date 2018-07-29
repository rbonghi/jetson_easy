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
MODULE_DEFAULT="AUTO"

script_check()
{
    if hash jetson_release 2>/dev/null; then
        # Read version
        local info_je=$(jetson_release)
        echo info_je
        # if old update
        return 1
        # otherwise don't care
        return 1 #temporary always true
    else
        return 1
    fi
}

script_run()
{
    tput setaf 6
    echo "Uninstall previous version of jetson_easy"
    tput sgr0
    
    # Move in jetson folder
    cd ../../jetson

    # Launch uninstaller jetson_easy
    . uninstall_jetson_easy.sh
    
    tput setaf 6
    echo "Install jetson_easy"
    tput sgr0
    
    # Launch installer jetson_easy
    . install_jetson_easy.sh
    
    tput setaf 6
    echo "Complete!"
    tput sgr0
}


