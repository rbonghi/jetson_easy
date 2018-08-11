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

# Install Deep learning frameworks

# Default variables load
MODULE_NAME="Install deep learning frameworks"
MODULE_DESCRIPTION="With this module you can install other deep learning modules, such as: TensorFlow, Caffe, Pytorch and other"
MODULE_DEFAULT="STOP"
MODULE_OPTIONS=("RUN" "STOP")

MODULE_SUBMENU=("Install deep learning module:dp_learning_list" "Set install folder:dp_set_install_folder")

script_load_default()
{
    if [ -z ${DP_PATCH_LIST+x} ] ; then
        # Empty packages patch list 
        DP_PATCH_LIST="\"\""
    fi
    
    if [ -z ${DP_FOLDER+x} ] ; then
        # Empty packages patch list 
        DP_FOLDER="$HOME"
    fi
}

script_save()
{    
    if [ ! -z ${DP_PATCH_LIST+x} ] ; then
        if [ $DP_PATCH_LIST != "\"\"" ]
        then
            echo "DP_PATCH_LIST=\"$DP_PATCH_LIST\"" >> $1
        fi
    fi
    
    if [ ! -z ${DP_FOLDER+x} ] ; then
        if [ $DP_FOLDER != "\"\"" ]
        then
            echo "DP_FOLDER=\"$DP_FOLDER\"" >> $1
        fi
    fi
}

script_info()
{
    echo " - Will be add this packages: $DP_PATCH_LIST"
    echo " - Installation folder: $DP_FOLDER"
}

dp_is_enabled()
{
    if [[ $PKGS_PATCH_LIST = *"$1"* ]] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

dp_learning_list()
{
    if [ -z ${DP_PATCH_LIST+x} ]
    then
        # Empty kernel patch list
        DP_PATCH_LIST="\"\""
    fi
    
    local PKGS_PATCH_LIST_TMP
    DP_PATCH_LIST_TMP=$(whiptail --title "$MODULE_NAME" --checklist \
    "Which new packages do you want add?" 15 75 6 \
    "caffe"  "A fast open framework" $(dp_is_enabled "caffe") \
    "caffe2" "Lightweight, modular, and scalable" $(dp_is_enabled "caffe2") \
    "tensorflow" "Open source machine learning framework" $(dp_is_enabled "tensorflow") \
    "torch7" "Scientific computing framework" $(dp_is_enabled "torch7") \
    "pyTorch" "Tensors & Dynamic neural networks in Python" $(dp_is_enabled "pyTorch") \
    "jetson-inference" "Inference net & deep vision with TensorRT" $(dp_is_enabled "jetson-inference") 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save list of new element to patch
        DP_PATCH_LIST="$DP_PATCH_LIST_TMP"
    fi
    
}

dp_set_install_folder()
{
    local dp_set_install_folder_temp
    ros_set_master_uri_temp=$(whiptail --inputbox "Set install folder" 8 78 $DP_FOLDER --title "Set install folder" 3>&1 1>&2 2>&3)
    
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Write new DP_FOLDER
        DP_FOLDER=$dp_set_install_folder_temp
    fi
}

