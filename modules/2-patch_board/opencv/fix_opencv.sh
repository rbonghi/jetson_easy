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


opencv3_check()
{
    local PATCH_OPENCV_VERSION=$1
    
    if [ "$PATCH_DOWNLOAD_OPENCV_FORCE" = "YES" ] ; then
        return 1
    fi
    
    if [ "$JETSON_OPENCV" = "NOT INSTALLED" ] ; then
        return 0
    else
        if [ $(jetson_vercomp $PATCH_OPENCV_VERSION $JETSON_OPENCV) -gt 0 ] ; then
            return 1
        else
            return 0
        fi
    fi
    
    if [ "$JETSON_OPENCV_CUDA" = "NO" ] ; then
        return 1
    fi
    # Otherwise return false
    return 0
}

patch_opencv3()
{   
    local PATCH_OPENCV_VERSION=$1
    opencv3_check $PATCH_OPENCV_VERSION
    if [ $? -eq 1 ] ; then
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
        patch_opencv3_patcher
        # Install from source OpenCV
        patch_opencv3_installer $PATCH_OPENCV_VERSION
        # reinstall again all visionworks libraries
        if [ $lib_visionworks == "YES" ] ; then
            tput setaf 3
            echo "Reinstall libvisionworks"
            tput sgr0
            
            sudo apt install -y libvisionworks-samples* libvisionworks-sfm-dev* libvisionworks-tracking-dev*
        fi
        # Check status installation
        echo "OpenCV $JETSON_OPENCV compiled CUDA: $JETSON_OPENCV_CUDA"
    else
        tput setaf 3
        echo "Not require to fix OpenCV $JETSON_OPENCV compiled CUDA: $JETSON_OPENCV_CUDA"
        tput sgr0
    fi
}

patch_opencv3_patcher()
{
    ### Remove all old opencv stuffs installed by JetPack (or OpenCV4Tegra)
    tput setaf 6
    echo "Remove all old opencv stuffs installed by JetPack (or OpenCV4Tegra)"
    tput sgr0
    
    sudo apt purge libopencv* -y

    sudo apt autoremove -y

    ### Upgrade all installed apt packages to the latest versions (optional)
    tput setaf 6
    echo "Upgrade all installed apt packages to the latest versions"
    tput sgr0
    
    sudo apt update -y
    sudo apt full-upgrade -y
    
    if [ $DISTRIB_RELEASE == "18.04" ] ; then
        tput setaf 6
        echo "For Ubuntu 18.04, add for OpenGL, ie"
        tput sgr0
        sudo apt install libgl1 libglvnd-dev
    fi

    ### Update gcc apt package to the latest version (highly recommended)
    tput setaf 6
    echo "Update gcc apt package to the latest version"
    tput sgr0
    
    sudo apt install --only-upgrade g++-5 cpp-5 gcc-5 -y
    
    ### Install dependencies based on the Jetson Installing OpenCV Guide
    tput setaf 6
    echo "Install dependencies based on the Jetson Installing OpenCV Guide"
    tput sgr0
    
    sudo apt install -y build-essential make cmake cmake-curses-gui \
                           g++ libavformat-dev libavutil-dev \
                           libswscale-dev libv4l-dev libeigen3-dev \
                           libglew-dev libgtk2.0-dev
    
    ### Install dependencies for gstreamer stuffs
    tput setaf 6
    echo "Install dependencies for gstreamer stuffs"
    tput sgr0
    
    sudo apt install -y libdc1394-22-dev libxine2-dev \
                           libgstreamer1.0-dev \
                           libgstreamer-plugins-base1.0-dev
    
    ### Install additional dependencies according to the pyimageresearch article
    tput setaf 6
    echo "Install additional dependencies according to the pyimageresearch"
    tput sgr0
    
    sudo apt install -y libjpeg8-dev libjpeg-turbo8-dev libtiff5-dev \
                           libjasper-dev libpng12-dev libavcodec-dev
    sudo apt install -y libxvidcore-dev libx264-dev libgtk-3-dev \
                           libatlas-base-dev gfortran
    
    ### Install Qt5 dependencies
    tput setaf 6
    echo "Install Qt5 dependencies"
    tput sgr0
    
    sudo apt install qt5-default -y
    
    ### Patch OpenCV3
    # https://devtalk.nvidia.com/default/topic/1007290/jetson-tx2/building-opencv-with-opengl-support-/post/5141945/#5141945
    #https://www.thegeekstuff.com/2014/12/patch-command-examples
    
    sudo patch -p0 -N --dry-run --silent /usr/local/cuda/include/cuda_gl_interop.h opencv/cuda_gl_interop.patch 2>/dev/null
    #If the patch has not been applied then the $? which is the exit status 
    #for last command would have a success status code = 0
    if [ $? -eq 0 ];
    then
        #apply the patch
        tput setaf 6
        echo "Patching CUDA file: /usr/local/cuda/include/cuda_gl_interop.h"
        tput sgr0
        sudo patch -N /usr/local/cuda/include/cuda_gl_interop.h opencv/cuda_gl_interop.patch
    else
        tput setaf 3
        echo "CUDA /usr/local/cuda/include/cuda_gl_interop.h has already patched!"
        tput sgr0
    fi
    
    # If exist the tegra file
    # https://devtalk.nvidia.com/default/topic/946136/
    if [ -f /usr/lib/aarch64-linux-gnu/tegra/libGL.so ]; then
        # Local folder
        local LOCAL_FOLDER=$(pwd)
    
        ### Fix the symbolic link of libGL.so
        tput setaf 6
        echo "Fix the symbolic link of libGL.so"
        tput sgr0
        cd /usr/lib/aarch64-linux-gnu/   
        
        sudo ln -sf tegra/libGL.so libGL.so
        
        # Restore previuous folder
        cd $LOCAL_FOLDER
    fi
}

patch_opencv3_installer()
{
    # Local variables
    local LOCAL_FOLDER=$(pwd)
    local NUM_CPU=$(nproc)
    local OPENCV_VERSION=$1
    local opencv_source_path="$PATCH_OPENCV_SOURCE_PATH"
    
    ### Download last stable opencv source code
    tput setaf 6
    echo "Download OpenCV $OPENCV_VERSION source code in $opencv_source_path"
    tput sgr0
    
    mkdir -p $opencv_source_path
    cd $opencv_source_path
    git clone https://github.com/opencv/opencv.git
    cd opencv
    git checkout -b v${OPENCV_VERSION} ${OPENCV_VERSION}

    if [ $PATCH_DOWNLOAD_OPENCV_CONTRIB == "YES" ] ; then
        echo "Installing opencv_contrib"
        git clone https://github.com/opencv/opencv_contrib.git
        cd opencv_contrib
        git checkout -b v${OPENCV_VERSION} ${OPENCV_VERSION}
        cd ..
    fi

    if [ $PATCH_DOWNLOAD_OPENCV_EXTRAS == "YES" ] ; then
        echo "Installing opencv_extras"
        git clone https://github.com/opencv/opencv_extra.git
        cd opencv_extra
        git checkout -b v${OPENCV_VERSION} ${OPENCV_VERSION}
        cd ..
    fi
    
    ### Build opencv (CUDA_ARCH_BIN="6.2" for TX2, or "5.3" for TX1)
    tput setaf 6
    echo "Build openCV with CUDA_ARCH_BIN=\"$JETSON_CUDA_ARCH_BIN\" for your $JETSON_DESCRIPTION"
    tput sgr0
    
    cd $opencv_source_path/opencv
    
    if [ -d "build" ] ; then
        tput setaf 6
        echo "Clean old BUILD"
        tput sgr0
        
        rm -R build
    fi
    mkdir build 
    cd build

    # Reference to cmake OpenCV
    # https://github.com/jetsonhacks/buildOpenCVXavier/blob/master/buildOpenCV.sh

    # Added for this release of Jetson AGX Xavier from Jetson TX2
    local opencv_xavier_option=""
    if [ $JETSON_BOARD == "Xavier" ] ; then
        opencv_xavier_option="-D CUDA_NVCC_FLAGS=\"--expt-relaxed-constexpr\" -D WITH_TBB=ON"
    fi
    
    # Add extra options for OpenCV contrib
    local opencv_contrib_option=""
    if [ $PATCH_DOWNLOAD_OPENCV_CONTRIB == "YES" ] ; then
        opencv_contrib_option="-D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules"
    fi
    
    # Add extra options for OpenCV extras
    local opencv_extras_option=""
    if [ $PATCH_DOWNLOAD_OPENCV_EXTRAS == "YES" ] ; then
        opencv_extras_option="-D INSTALL_TESTS=ON -D OPENCV_TEST_DATA_PATH=../opencv_extra/testdata"
    fi
    
    local opencv_test_option=""
    if [ $PATCH_DOWNLOAD_OPENCV_TEST == "YES" ] ; then
        opencv_test_option="-D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON"
    fi
    # There are also switches which tell CMAKE to build the samples and tests
    # Check OpenCV documentation for details

    time cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=$PATCH_OPENCV_INSTALL_PATH \
          -D WITH_CUDA=ON -D CUDA_ARCH_BIN=$JETSON_CUDA_ARCH_BIN -D CUDA_ARCH_PTX="" \
          -D WITH_CUBLAS=ON -D ENABLE_FAST_MATH=ON -D CUDA_FAST_MATH=ON \
          -D ENABLE_NEON=ON -D WITH_LIBV4L=ON -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF \
          -D WITH_GSTREAMER=ON -D WITH_GSTREAMER_0_10=OFF \
          -D WITH_QT=ON -D WITH_OPENGL=ON $opencv_xavier_option $opencv_contrib_option $opencv_extras_option ..

    if [ $? -eq 0 ] ; then
    
        tput setaf 6
        echo "CMake configuration make successful"
        tput sgr0
        
        tput setaf 6
        echo "Make openCV with $NUM_CPU CPU"
        tput sgr0
        time make -j$(($NUM_CPU - 1))

        tput setaf 6
        echo "Make install openCV"
        tput sgr0
        sudo make install

        tput setaf 6
        echo "ldconfig"
        tput sgr0
        sudo ldconfig
        
        tput setaf 6
        echo "Remove OpenCV $OPENCV_VERSION source code in $opencv_source_path"
        tput sgr0
        cd $PATCH_OPENCV_SOURCE_PATH
        sudo rm -R "opencv"
        
    else
      # Try to make again
      tput setaf 3
      echo "CMake issues " >&2
      echo "Please check the configuration being used"
      tput sgr0
    fi

    # Restore previuous folder
    cd $LOCAL_FOLDER
}

