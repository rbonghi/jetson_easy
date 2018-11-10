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

# https://devtalk.nvidia.com/default/topic/1027301/jetson-tx2/jetpack-3-2-mdash-l4t-r28-2-developer-preview-for-jetson-tx2/post/5225602/#5225602
# https://jkjung-avt.github.io/opencv3-on-tx2/

jp32_check()
{
    # Check if this jetpack require update return true
    local IFS
    local JETSON_JETPACK_VERS
    # Decode all JETSON_JETPACK versions
    IFS='|' read -ra JETSON_JETPACK_VERS <<< "$JETSON_JETPACK"
    local ver
    for ver in "${JETSON_JETPACK_VERS[@]}"; do
        #Clean from extra spaces
        ver=${ver//[[:blank:]]/}
        case $ver in
            "3.2"| "3.2.1" ) 
               return 1 ;;
            *) ;;
        esac
    done
    # Otherwise check  if other script require updates
    return 0
}

jp32_fix_key()
{
        # Fix apt-get update
        # https://devtalk.nvidia.com/default/topic/1030831/jetson-tx2/jetpack-3-2-mdash-l4t-r28-2-production-release-for-jetson-tx1-tx2/post/5245450/#5245450
        echo "Fix keys apt-get update"
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F60F4B3D7FA2AF80
        sudo apt update
}

