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


jp32_patch_opencv3()
{
    # Check if is correctly installed opencv3
    if ! jp32_opencv3_check ; then
        # Remove old opencv3 configuration
        jp32_patch_opencv3_installer
    else
        tput setaf 3
        echo "Correctly installed OpenCV3 with CUDA"
        tput sgr0
    fi
}

jp32_opencv3_check()
{
    # 0 = true - 1 = false
    return 1 
}

jp32_patch_opencv3_installer()
{
    ### Remove all old opencv stuffs installed by JetPack (or OpenCV4Tegra)
    tput setaf 6
    echo "Remove all old opencv stuffs installed by JetPack (or OpenCV4Tegra)"
    tput sgr0
    
    sudo apt-get purge libopencv* -y
    ### I prefer using newer version of numpy (installed with pip), so
    ### I'd remove this python-numpy apt package as well
    tput setaf 6
    echo "Remove python-numpy"
    tput sgr0
    
    sudo apt-get purge python-numpy -y
    ### Remove other unused apt packages
    tput setaf 6
    echo "Remove other unused apt packages"
    tput sgr0

    sudo apt autoremove -y

    ### Upgrade all installed apt packages to the latest versions (optional)
    tput setaf 6
    echo "Upgrade all installed apt packages to the latest versions"
    tput sgr0
    
    sudo apt-get update -y
    sudo apt-get dist-upgrade -y

    ### Update gcc apt package to the latest version (highly recommended)
    tput setaf 6
    echo "Update gcc apt package to the latest version"
    tput sgr0
    
    sudo apt-get install --only-upgrade g++-5 cpp-5 gcc-5 -y
    
    ### Install dependencies based on the Jetson Installing OpenCV Guide
    tput setaf 6
    echo "Install dependencies based on the Jetson Installing OpenCV Guide"
    tput sgr0
    
    sudo apt-get install -y build-essential make cmake cmake-curses-gui \
                           g++ libavformat-dev libavutil-dev \
                           libswscale-dev libv4l-dev libeigen3-dev \
                           libglew-dev libgtk2.0-dev
    
    ### Install dependencies for gstreamer stuffs
    tput setaf 6
    echo "Install dependencies for gstreamer stuffs"
    tput sgr0
    
    sudo apt-get install -y libdc1394-22-dev libxine2-dev \
                           libgstreamer1.0-dev \
                           libgstreamer-plugins-base1.0-dev
    
    ### Install additional dependencies according to the pyimageresearch article
    tput setaf 6
    echo "Install additional dependencies according to the pyimageresearch"
    tput sgr0
    
    sudo apt-get install -y libjpeg8-dev libjpeg-turbo8-dev libtiff5-dev \
                           libjasper-dev libpng12-dev libavcodec-dev
    sudo apt-get install -y libxvidcore-dev libx264-dev libgtk-3-dev \
                           libatlas-base-dev gfortran
    
    ### Install Qt5 dependencies
    tput setaf 6
    echo "Install Qt5 dependencies"
    tput sgr0
    
    sudo apt-get install qt5-default -y
    
    ### Install dependencies for python3
    tput setaf 6
    echo "Install dependencies for python3"
    tput sgr0
    
    export LC_ALL=C
    
    sudo apt-get install python3-dev python3-pip python3-tk -y
    sudo pip3 install numpy
    sudo pip3 install matplotlib
   
    ### Modify matplotlibrc (line #41) as 'backend      : TkAgg'
    # sudo gedit /usr/local/lib/python3.5/dist-packages/matplotlib/mpl-data/matplotlibrc
    tput setaf 6
    echo "Modify matplotlibrc (python 3) (line #41) as 'backend      : TkAgg"
    tput sgr0
    
    sudo sed -i 's/backend      : gtk3agg/backend      : TkAgg/' /usr/local/lib/python3.5/dist-packages/matplotlib/mpl-data/matplotlibrc
    
    ### Also install dependencies for python2
    ### Note that I install numpy with pip, so that I'd be using a newer
    ### version of numpy than the apt-get package
    sudo apt-get install python-dev python-pip python-tk -y
    sudo pip2 install numpy
    sudo pip2 install matplotlib
    
    ### Modify matplotlibrc (line #41) as 'backend      : TkAgg'
    # sudo vim /usr/local/lib/python2.7/dist-packages/matplotlib/mpl-data/matplotlibrc
    tput setaf 6
    echo "Modify matplotlibrc (python 2.7) (line #41) as 'backend      : TkAgg"
    tput sgr0
    
    sudo sed -i 's/backend      : gtk3agg/backend      : TkAgg/' /usr/local/lib/python3.5/dist-packages/matplotlib/mpl-data/matplotlibrc
}
