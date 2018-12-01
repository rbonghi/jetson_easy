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
# https://www.elinux.org/Jetson_TX2

# Tensorflow for jetson 
# https://github.com/peterlee0127/tensorflow-nvJetson
# https://www.jetsonhacks.com/2017/03/24/caffe-deep-learning-framework-nvidia-jetson-tx2/
# Torch7
# http://torch.ch/
# https://github.com/dusty-nv/jetson-reinforcement/blob/master/CMakePreBuild.sh
# Pytorch
# https://pytorch.org/
# https://gist.github.com/dusty-nv/ef2b372301c00c0a9d3203e42fd83426#file-pytorch_jetson_install-sh
# Jetson-Inference
# https://github.com/dusty-nv/jetson-inference

# Default variables load
MODULE_NAME="Install deep learning frameworks"
MODULE_DESCRIPTION="With this module you can install other deep learning modules, such as: TensorFlow, Caffe, Pytorch and other"
MODULE_DEFAULT="STOP"
MODULE_OPTIONS=("RUN" "STOP")

MODULE_SUBMENU=("Install deep learning module:dp_learning_list" "Set install folder:dp_set_install_folder")

dp_is_enabled()
{
    if [[ $DP_PATCH_LIST = *"$1"* ]] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

script_run()
{

    if [ $(dp_is_enabled "tensorflow") == "ON" ] ; then
        tput setaf 6
        echo "Install tensorflow"
        tput sgr0
        dp_install_tensorflow
    fi
    
    if [ $(dp_is_enabled "pyTorch") == "ON" ] ; then
        tput setaf 6
        echo "Install pyTorch"
        tput sgr0
        dp_install_pytorch
    fi
    
    if [ $(dp_is_enabled "jetson-inference") == "ON" ] ; then
        tput setaf 6
        echo "Install jetson-inference"
        tput sgr0
        dp_install_jetson_inference
    fi
}

dp_install_jetson_inference()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    local NUM_CPU=$(nproc)
    
    tput setaf 6
    echo "Install git and cmake"
    tput sgr0
    sudo apt-get install git cmake
    
    tput setaf 6
    echo "Clone jetson-inference repository from @dusty-nv"
    tput sgr0
    git clone https://github.com/dusty-nv/jetson-inference
    
    tput setaf 6
    echo "Configuring CMAKE"
    tput sgr0
    cd jetson-inference
    mkdir build
    cd build
    time cmake ../
    
    tput setaf 6
    echo "Make jetson-inference with $NUM_CPU CPU"
    tput sgr0
    time make -j$(($NUM_CPU - 1))
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

dp_install_pytorch()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    tput setaf 6
    echo "Download pytorch install script from @dusty-nv script"
    tput sgr0
    # Download pytorch
    wget https://gist.githubusercontent.com/dusty-nv/ef2b372301c00c0a9d3203e42fd83426/raw/b4086f39f4b53c5ed184cf4d1bb246c1ee16d6c0/pytorch_jetson_install.sh
    
    chmod +x pytorch_jetson_install.sh
    
    tput setaf 6
    echo "Run install script"
    tput sgr0
    ./pytorch_jetson_install.sh
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

dp_install_tensorflow_32()
{
    local DP_TENSORFLOW=""
    # Decode all JETSON_JETPACK versions
    IFS='|' read -ra JETSON_JETPACK_VERS <<< "$JETSON_JETPACK"
    local ver
    for ver in "${JETSON_JETPACK_VERS[@]}"; do
        #Clean from extra spaces
        ver=${ver//[[:blank:]]/}
        case $ver in
            "3.2"| "3.2.1" ) 
                    # Add version of tensorflow
                    DP_TENSORFLOW=tensorflow-1.10.0rc0-cp27-cp27mu-linux_aarch64.whl
                    #DP_TENSORFLOW=tensorflow-1.9.0-cp35-cp35m-linux_aarch64.whl
                    ;;
            *) ;;
        esac
    done
}

dp_install_tensorflow_check32()
{
    # Decode all JETSON_JETPACK versions
    IFS='|' read -ra JETSON_JETPACK_VERS <<< "$JETSON_JETPACK"
    local ver
    for ver in "${JETSON_JETPACK_VERS[@]}"; do
        #Clean from extra spaces
        ver=${ver//[[:blank:]]/}
        case $ver in
            "3.2"| "3.2.1" ) 
                    # Add version of tensorflow
                    echo "tensorflow-1.10.0rc0-cp27-cp27mu-linux_aarch64.whl"
                    return
                    #DP_TENSORFLOW=tensorflow-1.9.0-cp35-cp35m-linux_aarch64.whl
                    ;;
            *) echo "" 
               return ;;
        esac
    done
}

dp_install_tensorflow()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)
            
    local DP_TENSORFLOW=""
    
    # If is Jetpack 3.2 follow another line to install TensorFlow
    DP_TENSORFLOW=$(dp_install_tensorflow_check32)
    if [ ! -z "$DP_TENSORFLOW" ] ; then
        # Move to selected folder
        cd $DP_FOLDER
        
        tput setaf 6
        echo "Download and install pip"
        tput sgr0
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        sudo python get-pip.py
        
        tput setaf 6
        echo "Downloading in $DP_FOLDER Tensorflow $DP_TENSORFLOW"
        echo "Tensorflow $DP_TENSORFLOW"
        echo "Thanks @peterlee0127"
        tput sgr0
        # Download last version of tensor flow
        wget --output-document $DP_TENSORFLOW https://github.com/peterlee0127/tensorflow-nvJetson/releases/download/binary/$DP_TENSORFLOW
        
        tput setaf 6
        echo "Install Tensorflow $DP_TENSORFLOW"
        tput sgr0
        # Install tensorflow
        sudo pip install $DP_TENSORFLOW
        
        # Remove file
        #sudo rm $DP_TENSORFLOW
        
        # Restore previuous folder
        cd $LOCAL_FOLDER
    else
    
        local DP_TENSORFLOW_VERSION=""
        # Decode all JETSON_JETPACK versions
        IFS='|' read -ra JETSON_JETPACK_VERS <<< "$JETSON_JETPACK"
        local ver
        for ver in "${JETSON_JETPACK_VERS[@]}"; do
            #Clean from extra spaces
            ver=${ver//[[:blank:]]/}
            case $ver in
                "4.1"| "4.1.1" ) 
                        DP_TENSORFLOW_VERSION="41"
                        ;;
                "4.0") 
                        DP_TENSORFLOW_VERSION="40"
                        ;;
                "3.3") 
                        DP_TENSORFLOW_VERSION="33"
                        ;;
                *) ;;
            esac
        done
        
        # Check if is selected the version of tensorflow to install
        if [ ! -z $DP_TENSORFLOW_VERSION ] ; then
            tput setaf 6
            echo "Download and install pip"
            tput sgr0
            sudo apt-get install python-pip
            tput setaf 6
            echo "Download and install pip3"
            tput sgr0
            sudo apt-get install python3-pip
        
            tput setaf 6
            echo "Install Tensorflow $DP_TENSORFLOW for python2.7"
            tput sgr0
            pip install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v$DP_TENSORFLOW_VERSION tensorflow-gpu
            tput setaf 6
            echo "Install Tensorflow $DP_TENSORFLOW for python3.6"
            tput sgr0
            pip3 install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v$DP_TENSORFLOW_VERSION tensorflow-gpu
            
        else
            tput setaf 1
            echo "I can't install Tensorflow, any Jetpack is recognized!"
            tput sgr0
        fi
    fi
}

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
        if [ $DP_FOLDER != "\"\"" ] ; then
            echo "DP_FOLDER=\"$DP_FOLDER\"" >> $1
        fi
    fi
}

script_info()
{
    echo " - Will be add this packages: $DP_PATCH_LIST"
    echo " - Installation folder: $DP_FOLDER"
}

dp_learning_list()
{
    if [ -z ${DP_PATCH_LIST+x} ] ; then
        # Empty kernel patch list
        DP_PATCH_LIST="\"\""
    fi
    
    #"caffe"  "A fast open framework" $(dp_is_enabled "caffe") \
    #"caffe2" "Lightweight, modular, and scalable" $(dp_is_enabled "caffe2") \
    #"torch7" "Scientific computing framework" $(dp_is_enabled "torch7") \
    
    local PKGS_PATCH_LIST_TMP
    DP_PATCH_LIST_TMP=$(whiptail --title "$MODULE_NAME" --checklist \
    "Which new packages do you want add?" 15 75 3 \
    "tensorflow" "Open source machine learning framework" $(dp_is_enabled "tensorflow") \
    "pyTorch" "Tensors & Dynamic neural networks in Python" $(dp_is_enabled "pyTorch") \
    "jetson-inference" "Inference net & deep vision with TensorRT" $(dp_is_enabled "jetson-inference") 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
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

