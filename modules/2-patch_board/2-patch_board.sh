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


# Reference
# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash

# Patch the board from knowed errors
MODULE_NAME="Patch $JETSON_DESCRIPTION from known errors"
MODULE_DESCRIPTION="Patch $JETSON_DESCRIPTION from known errors"
MODULE_DEFAULT="AUTO"

# Know errors for Jetpack 3.2
# https://devtalk.nvidia.com/default/topic/1031736/jetson-tx2/cuda-9-0-samples-do-not-build-with-jetpack-3-2/
# https://devtalk.nvidia.com/default/topic/1027301/jetson-tx2/jetpack-3-2-mdash-l4t-r28-2-developer-preview-for-jetson-tx2/post/5225602/#5225602
# https://devtalk.nvidia.com/default/topic/1030831/jetson-tx2/jetpack-3-2-mdash-l4t-r28-2-production-release-for-jetson-tx1-tx2/post/5245450/#5245450

# Load jetpack scripts
source $(pwd)/modules/2-patch_board/jp32_patch.sh
# Check if is require to patch jetson or NOT
jp32_check
if [ $? -eq 1 ] ; then
    PATCH_JETPACK="YES"
else
    PATCH_JETPACK="NO"
fi

# Load source
source $(pwd)/modules/2-patch_board/cuda_examples/fix_cuda_example.sh
# Check cuda examples
cuda_examples_check
if [ $? -eq 1 ] ; then
    PATCH_CUDA_EXAMPLES="YES"
else
    PATCH_CUDA_EXAMPLES="NO"
fi

patch_opencv_set_contrib()
{
    local patch_opencv_set_contrib_temp
    patch_opencv_set_contrib_temp=$(whiptail --title "$MODULE_NAME - Install contrib" --radiolist \
    "Do you want install OpenCV with Contrib?" 15 60 2 \
    "YES" "Install Contrib" $(common_load_check "YES" $PATCH_DOWNLOAD_OPENCV_CONTRIB) \
    "NO" "Without Contrib" $(common_load_check "NO" $PATCH_DOWNLOAD_OPENCV_CONTRIB) 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        PATCH_DOWNLOAD_OPENCV_CONTRIB=$patch_opencv_set_contrib_temp
    fi
    patch_opencv
}

patch_opencv_set_extras()
{
    local patch_opencv_set_extras_temp
    patch_opencv_set_extras_temp=$(whiptail --title "$MODULE_NAME - Install extras" --radiolist \
    "Do you want install OpenCV with Extras?" 15 60 2 \
    "YES" "Install Extras" $(common_load_check "YES" $PATCH_DOWNLOAD_OPENCV_EXTRAS) \
    "NO" "Without Extras" $(common_load_check "NO" $PATCH_DOWNLOAD_OPENCV_EXTRAS) 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        PATCH_DOWNLOAD_OPENCV_EXTRAS=$patch_opencv_set_extras_temp
    fi
    patch_opencv
}

patch_opencv_set_version()
{
    local patch_opencv_menu_temp
    patch_opencv_menu_temp=$(whiptail --inputbox "Write the ONLY version number you want install" 8 78 $PATCH_OPENCV_VERSION --title "$MODULE_NAME - OpenCV version number" 3>&1 1>&2 2>&3)
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save openCV version
        PATCH_OPENCV_VERSION=$patch_opencv_menu_temp
    fi
    patch_opencv
}

patch_opencv_set_source_path()
{
    local patch_opencv_source_path_temp
    patch_opencv_source_path_temp=$(whiptail --inputbox "Write where will be download all opencv source path" 8 78 $PATCH_OPENCV_SOURCE_PATH --title "$MODULE_NAME - OpenCV source path" 3>&1 1>&2 2>&3)
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save openCV version
        PATCH_OPENCV_SOURCE_PATH=$patch_opencv_source_path_temp
    fi
    patch_opencv
}

patch_opencv_set_install_path()
{
    local patch_opencv_install_path_temp
    patch_opencv_install_path_temp=$(whiptail --inputbox "Write where will be installed opencv" 8 78 $PATCH_OPENCV_INSTALL_PATH --title "$MODULE_NAME - OpenCV install path" 3>&1 1>&2 2>&3)
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save openCV version
        PATCH_OPENCV_INSTALL_PATH=$patch_opencv_install_path_temp
    fi
    patch_opencv
}

patch_opencv()
{
    local patch_opencv_menu_temp
    patch_opencv_menu_temp=$(whiptail --title "Set wstool option" --menu "Select type of wstool configuration" 10 60 5 "version" "Set OpenCV version v$PATCH_OPENCV_VERSION" "source" "OpenCV source path: $PATCH_OPENCV_SOURCE_PATH" "install" "OpenCV install path: $PATCH_OPENCV_SOURCE_PATH" "contrib" "[$(common_is_check $PATCH_DOWNLOAD_OPENCV_CONTRIB)] Install OpenCV with contrib" "extras" "[$(common_is_check $PATCH_DOWNLOAD_OPENCV_EXTRAS)] Install OpenCV with Extras" 3>&1 1>&2 2>&3)
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case $patch_opencv_menu_temp in
            "version") patch_opencv_set_version ;;
            "source") patch_opencv_set_source_path ;;
            "install") patch_opencv_set_install_path ;;
            "contrib") patch_opencv_set_contrib ;;
            "extras") patch_opencv_set_extras ;;
            *) ;;
        esac
    fi
}

patch_jetpack()
{
    whiptail --title "$MODULE_NAME - Update This $JETSON_JETPACK" --textbox /dev/stdin 10 45 <<< "Update This $JETSON_JETPACK with last fixes"
}

patch_cuda_examples()
{
    whiptail --title "$MODULE_NAME - Fix all CUDA examples" --textbox /dev/stdin 10 45 <<< "Fix all CUDA $JETSON_CUDA examples"
}

############################################

script_load_default()
{
    # Write openCV version
    if [ -z ${PATCH_OPENCV_VERSION+x} ] ; then
        PATCH_OPENCV_VERSION=3.4.0
    fi
    
    # Write openCV source path
    if [ -z ${PATCH_OPENCV_SOURCE_PATH+x} ] ; then
        PATCH_OPENCV_SOURCE_PATH="/tmp"
    fi
    
    # Write openCV path
    if [ -z ${PATCH_OPENCV_INSTALL_PATH+x} ] ; then
        PATCH_OPENCV_INSTALL_PATH="/usr/local"
    fi
    
    # Write openCV with contrib
    if [ -z ${PATCH_DOWNLOAD_OPENCV_CONTRIB+x} ] ; then
        PATCH_DOWNLOAD_OPENCV_CONTRIB="NO"
    fi
    
    # Write openCV with extras
    if [ -z ${PATCH_DOWNLOAD_OPENCV_EXTRAS+x} ] ; then
        PATCH_DOWNLOAD_OPENCV_EXTRAS="NO"
    fi
}

script_save()
{
    # OpenCV version
    if [ ! -z ${PATCH_OPENCV_VERSION+x} ] && [ ! -z $PATCH_OPENCV_VERSION ] ; then
        echo "PATCH_OPENCV_VERSION=\"$PATCH_OPENCV_VERSION\"" >> $1
    fi
    
    # OpenCV source path
    if [ ! -z ${PATCH_OPENCV_SOURCE_PATH+x} ] && [ ! -z $PATCH_OPENCV_SOURCE_PATH ] ; then
        echo "PATCH_OPENCV_SOURCE_PATH=\"$PATCH_OPENCV_SOURCE_PATH\"" >> $1
    fi
    
    # OpenCV install path
    if [ ! -z ${PATCH_OPENCV_INSTALL_PATH+x} ] && [ ! -z $PATCH_OPENCV_INSTALL_PATH ] ; then
        echo "PATCH_OPENCV_INSTALL_PATH=\"$PATCH_OPENCV_INSTALL_PATH\"" >> $1
    fi
    
    # OpenCV with contrib
    if [ ! -z ${PATCH_DOWNLOAD_OPENCV_CONTRIB+x} ] && [ ! -z $PATCH_DOWNLOAD_OPENCV_CONTRIB ] ; then
        echo "PATCH_DOWNLOAD_OPENCV_CONTRIB=\"$PATCH_DOWNLOAD_OPENCV_CONTRIB\"" >> $1
    fi
    
    # OpenCV with contrib
    if [ ! -z ${PATCH_DOWNLOAD_OPENCV_EXTRAS+x} ] && [ ! -z $PATCH_DOWNLOAD_OPENCV_EXTRAS ] ; then
        echo "PATCH_DOWNLOAD_OPENCV_EXTRAS=\"$PATCH_DOWNLOAD_OPENCV_EXTRAS\"" >> $1
    fi
}

script_check()
{
    if [ $PATCH_JETPACK == "YES" ] ; then
        return 1
    fi
    
    # Load fix_opencv.sh script
    source opencv/fix_opencv.sh
    # Check opencv3
    opencv3_check $PATCH_OPENCV_VERSION
    if [ $? -eq 1 ] ; then
        return 1
    fi

    # Check cuda examples
    if [ $PATCH_CUDA_EXAMPLES == "YES" ] ; then
        return 1
    fi
    # Otherwise return 0
    return 0
}

script_info()
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
               echo "    - Fix errors in Jetpack $ver"
               break ;;
            *) ;;
        esac
    done
    
    # Load fix_opencv.sh script
    source opencv/fix_opencv.sh
    # Check opencv3
    opencv3_check $PATCH_OPENCV_VERSION
    if [ $? -eq 1 ] ; then
        echo "    - Update OpenCV $JETSON_OPENCV to $PATCH_OPENCV_VERSION and enable CUDA"
    fi
    # Load source
    source cuda_examples/fix_cuda_example.sh
    # Check cuda examples
    cuda_examples_check
    if [ $? -eq 1 ] ; then
        echo "    - Update Cuda Examples"
    fi
}

script_run()
{
    tput setaf 6
    echo "Patch $JETSON_DESCRIPTION from known errors"
    tput sgr0
    
    # Decode all JETSON_JETPACK versions and run script check
    IFS='|' read -ra JETSON_JETPACK_VERS <<< "$JETSON_JETPACK"
    local ver
    for ver in "${JETSON_JETPACK_VERS[@]}"; do
        #Clean from extra spaces
        ver=${ver//[[:blank:]]/}
        case $ver in
            "3.2"| "3.2.1" ) # Run jp32 fix key
                             source jp32_patch.sh
                             jp32_fix_key
                             ;;
            *) ;;
        esac
    done
    
    # Load fix_opencv.sh script
    source opencv/fix_opencv.sh
    tput setaf 6
    echo "Pach opencv in $JETSON_JETPACK"
    tput sgr0
    # Run patcher
    patch_opencv3 $PATCH_OPENCV_VERSION
    
    # Load source
    source cuda_examples/fix_cuda_example.sh
    # Run cuda examples patch
    patch_cuda_examples
}


## Name distribution
MODULE_SUBMENU=("Configure OpenCV:patch_opencv" )

if [ ! -z ${PATCH_JETPACK+x} ] && [ $PATCH_JETPACK == "YES" ] ; then
    MODULE_SUBMENU+=("Patch Jetpack:patch_jetpack" )
fi

if [ ! -z ${PATCH_CUDA_EXAMPLES+x} ] && [ $PATCH_CUDA_EXAMPLES == "YES" ] ; then
    MODULE_SUBMENU+=("Patch CUDA Examples:patch_cuda_examples" )
fi
