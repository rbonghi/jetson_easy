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

# Following
# https://devtalk.nvidia.com/default/topic/1031736/jetson-tx2/cuda-9-0-samples-do-not-build-with-jetpack-3-2/
jp32_patch_cuda_examples()
{
    if [ -d $HOME/NVIDIA_CUDA-9.0_Samples ] ; then
        sudo patch -p0 -N --dry-run --silent $HOME/NVIDIA_CUDA-9.0_Samples/6_Advanced/cdpLUDecomposition/Makefile jp32/cuda_sample.patch 2>/dev/null
        #If the patch has not been applied then the $? which is the exit status 
        #for last command would have a success status code = 0
        if [ $? -eq 0 ];
        then
            #apply the patch
            tput setaf 6
            echo "Patching CUDA example in $HOME/NVIDIA_CUDA-9.0_Samples"
            tput sgr0
            sudo patch -N $HOME/NVIDIA_CUDA-9.0_Samples/6_Advanced/cdpLUDecomposition/Makefile jp32/cuda_sample.patch
        else
            tput setaf 3
            echo "CUDA example in /usr/local/cuda-9.0/samples has already patched!"
            tput sgr0
        fi
    fi
    
    if [ -d /usr/local/cuda-9.0/samples ] ; then
        tput setaf 6
        echo "Patching CUDA example in /usr/local/cuda-9.0/samples"
        tput sgr0
        
        sudo patch -p0 -N --dry-run --silent /usr/local/cuda-9.0/samples/6_Advanced/cdpLUDecomposition/Makefile jp32/cuda_sample.patch 2>/dev/null
        #If the patch has not been applied then the $? which is the exit status 
        #for last command would have a success status code = 0
        if [ $? -eq 0 ];
        then
            #apply the patch
            tput setaf 6
            echo "Patching CUDA example in /usr/local/cuda-9.0/samples"
            tput sgr0
        
            sudo patch -N /usr/local/cuda-9.0/samples/6_Advanced/cdpLUDecomposition/Makefile jp32/cuda_sample.patch
        else
            tput setaf 3
            echo "CUDA example in /usr/local/cuda-9.0/samples has already patched!"
            tput sgr0
        fi
    fi
}

jp32_patch_opencv3()
{
    if ! jp32_opencv3_check ; then
        tput setaf 6
        echo "Fix OpenCV $JETSON_OPENCV with CUDA"
        tput sgr0
        # Check if installed libvisionworks
        local lib_visionworks="NO"
        if dpkg -s "libvisionworks" >/dev/null ; then
            tput setaf 3
            echo "libvisionworks is installed."
            tput sgr0
            
            lib_visionworks="YES"
        fi
        # Remove old opencv3 configuration
        jp32_patch_opencv3_patcher
        # Install from source OpenCV
        jp32_patch_opencv3_installer
        # reinstall again all visionworks libraries
        if [ $lib_visionworks == "YES" ] ; then
            tput setaf 3
            echo "Reinstall libvisionworks"
            tput sgr0
            
            sudo apt install -y libvisionworks-samples* libvisionworks-sfm-dev* libvisionworks-tracking-dev*
        fi
        # Check status installation
        jp32_opencv3_check
    else
        tput setaf 3
        echo "Skip OpenCV3 with CUDA patcher"
        tput sgr0
    fi
}

jp32_opencv3_check()
{
    # 0 = true - 1 = false
    
    local OPENCV_VERSION_VERBOSE=""
    if hash opencv_version 2>/dev/null; then
        # Red if use CUDA or not
        OPENCV_VERSION_VERBOSE=$(opencv_version --verbose | grep "Use Cuda" )
        
        if [[ !  -z  $OPENCV_VERSION_VERBOSE  ]] ; then
            # Read status of CUDA
            local OPENCV_CUDA_FLAG=$(echo $OPENCV_VERSION_VERBOSE | cut -f2 -d ':' )
            # Remvoe all spaces
            OPENCV_CUDA_FLAG=${OPENCV_CUDA_FLAG//[[:blank:]]/}
            
            if [ $OPENCV_CUDA_FLAG == "NO" ] ; then
                tput setaf 3
                echo "OpenCV $JETSON_OPENCV Cuda not installed"
                tput sgr0
                
                false
            else
                tput setaf 3
                echo "OpenCV $JETSON_OPENCV Cuda installed"
                tput sgr0
                
                return 0
            fi

        else
            # read NVIDIA CUDA version
            OPENCV_VERSION_VERBOSE=$(opencv_version --verbose | grep "NVIDIA CUDA" )
            # get information
            OPENCV_CUDA_FLAG=$(echo $OPENCV_VERSION_VERBOSE | cut -f2 -d ':')
            OPENCV_CUDA_FLAG=${OPENCV_CUDA_FLAG//[[:blank:]]/}
            
            tput setaf 3
            echo "OpenCV with CUDA is installed correctly - OpenCV $OPENCV_CUDA_FLAG"
            tput sgr0
            
            return 0
        fi
    else
        tput setaf 3
        echo "OpenCV not installed not required to patch"
        tput sgr0
        
        return 0
    fi
}

jp32_patch_opencv3_patcher()
{
    ### Remove all old opencv stuffs installed by JetPack (or OpenCV4Tegra)
    tput setaf 6
    echo "Remove all old opencv stuffs installed by JetPack (or OpenCV4Tegra)"
    tput sgr0
    
    sudo apt-get purge libopencv* -y

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
    
    ### Patch OpenCV3
    # https://devtalk.nvidia.com/default/topic/1007290/jetson-tx2/building-opencv-with-opengl-support-/post/5141945/#5141945
    tput setaf 6
    echo "Patching cuda_gl_interop.h"
    tput sgr0
    
    #https://www.thegeekstuff.com/2014/12/patch-command-examples
    sudo patch /usr/local/cuda/include/cuda_gl_interop.h jp32/cuda_gl_interop.patch
    
    ### Fix the symbolic link of libGL.so
    tput setaf 6
    echo "Fix the symbolic link of libGL.so"
    tput sgr0
    
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    cd /usr/lib/aarch64-linux-gnu/
    
    sudo ln -sf tegra/libGL.so libGL.so
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

jp32_patch_opencv3_installer()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    local NUM_CPU=$(nproc)
    local opencv_version="opencv-3.4.0"
    local opencv_source_folder="/tmp/$opencv_version"
    
    local cuda_arch=""
    if [ $JETSON_BOARD == "TX2" ] || [ $JETSON_BOARD == "TX2i" ] ; then
        cuda_arch="6.2"
    elif [ $JETSON_BOARD == "TX1" ] ; then
        cuda_arch="5.3"
    else
        tput setaf 1
        echo "This patch doesn't work for your $JETSON_DESCRIPTION!"
        tput sgr0
        # Return error
        return 1
    fi
    
    ### Download opencv-3.4.0 source code
    tput setaf 6
    echo "Download $opencv_version source code"
    tput sgr0
    
    mkdir -p $opencv_source_folder
    cd $opencv_source_folder
    wget https://github.com/opencv/opencv/archive/3.4.0.zip -O $opencv_version.zip
    unzip $opencv_version.zip
    
    ### Build opencv (CUDA_ARCH_BIN="6.2" for TX2, or "5.3" for TX1)
    tput setaf 6
    echo "Build openCV with CUDA_ARCH_BIN=\"$cuda_arch\" for your $JETSON_DESCRIPTION"
    tput sgr0
    
    cd $opencv_source_folder/$opencv_version
    
    mkdir build
    
    cd build

    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_CUDA=ON -D CUDA_ARCH_BIN=$cuda_arch -D CUDA_ARCH_PTX="" \
          -D WITH_CUBLAS=ON -D ENABLE_FAST_MATH=ON -D CUDA_FAST_MATH=ON \
          -D ENABLE_NEON=ON -D WITH_LIBV4L=ON -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF \
          -D WITH_QT=ON -D WITH_OPENGL=ON ..

    tput setaf 6
    echo "Make openCV with $NUM_CPU CPU"
    tput sgr0
    make -j$NUM_CPU
    
    tput setaf 6
    echo "Make install openCV"
    tput sgr0
    sudo make install
    
    tput setaf 6
    echo "Remove $opencv_version source code"
    tput sgr0
    sudo rm -R $opencv_source_folder
    
    tput setaf 6
    echo "ldconfig"
    tput sgr0
    sudo ldconfig
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

jp32_patch_mathplotlib()
{
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
