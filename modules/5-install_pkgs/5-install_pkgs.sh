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

# Install standard packages

MODULE_NAME="Install standard packages"
MODULE_DESCRIPTION="Install standard packages:
htop
nano
vs_oss
synergy
guake
rtabmap"
MODULE_DEFAULT="STOP"
MODULE_OPTIONS=("RUN" "STOP")

MODULE_SUBMENU=("Add new packages:set_pkgs")

#Will add check for Zed version status later.
INSTALL_ZED_VERSION="2.7"

pkgs_is_enabled()
{
    if [[ $PKGS_PATCH_LIST = *"$1"* ]] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

install_pkgs_jupyter()
{
    # http://jupyter.org/install
    # https://github.com/jupyterhub/jupyterhub/wiki/Installation-of-Jupyterhub-on-remote-server
    # https://jupyter-notebook.readthedocs.io/en/stable/public_server.html
    # http://blog.lerner.co.il/five-minute-guide-setting-jupyter-notebook-server/
    # https://aichamp.wordpress.com/2017/06/13/setting-up-jupyter-notebook-server-as-service-in-ubuntu-16-04/
    # https://github.com/dusty-nv/jetson-reinforcement/issues/21
    
    sudo apt install python3-pip
    
    python3 -m pip install --upgrade pip
    python3 -m pip install --user jupyter
    
    # Add in bashrc
    
    # Add Jupiter path
    export PATH=${PATH}:~/.local/bin
    
    # TODO
    # write service module for jupyter
    
    echo "None"
}

script_run()
{
    echo "Install standard packages"
    
    if [ $(pkgs_is_enabled "htop") == "ON" ] ; then
    #installs htop
        tput setaf 6
        echo "Install htop"
        tput sgr0
        sudo apt install htop -y
    fi

    if [ $(pkgs_is_enabled "vs_oss") == "ON" ] ; then
    #installs Visual Studio code, compatible with Jetson Xavier, not tested on Tx2 or Tx1. Most likley will work.
        tput setaf 6
        echo "Install Visual Studio"
        tput sgr0
        install_vs
    fi
    
    if [ $(pkgs_is_enabled "nano") == "ON" ] ; then
        tput setaf 6
        echo "Install nano"
        tput sgr0
        sudo apt install nano -y
    fi

    if [ $(pkgs_is_enabled "rtabmap") == "ON" ] ; then
    #Installs RTABMAP with Zed sdk support in Rtab stettings.
        tput setaf 6
        echo "Install RTABMAP with Zed SDK support"
        tput sgr0
        ros_install_rtabmap
    fi

    if [ $(pkgs_is_enabled "guake") == "ON" ] ; then
        tput setaf 6
        echo "Install guake"
        tput sgr0
        sudo apt install guake -y
    fi

    if [ $(pkgs_is_enabled "synergy") == "ON" ] ; then
    #Used for sharing the mouse and keyboard from other devices. Works with Linux/Mac/Windows.
        tput setaf 6
        echo "Install synergy"
        tput sgr0
        wget -q -O - http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
        sudo sh -c 'echo "deb http://archive.getdeb.net/ubuntu trusty-getdeb apps" >> /etc/apt/sources.list.d/getdeb.list'
        sudo apt-get update
        sudo apt-get install synergy -y
    fi

    if [ $(pkgs_is_enabled "iftop") == "ON" ] ; then
        tput setaf 6
        echo "Install iftop"
        tput sgr0
        sudo apt install iftop -y
    fi
    
    if [ $(pkgs_is_enabled "ZED") == "ON" ] ; then
    
        # Check if is installed CUDA
        if [ ! -z ${JETSON_CUDA+x} ] ; then
            tput setaf 6
            echo "Install ZED driver on $JETSON_DESCRIPTION [L4T $JETSON_L4T] with CUDA $JETSON_CUDA"
            tput sgr0
            local JETSON_NAME
            # Select version board
            if [ $JETSON_BOARD == "Xavier" ] ; then
                 JETSON_NAME="tegraxavier"
            elif [ $JETSON_BOARD == "TX1" ] ; then
                JETSON_NAME="tegrax1"
            elif [ $JETSON_BOARD == "TX2" ] || [ $JETSON_BOARD == "TX2i" ] ; then
                JETSON_NAME="tegrax2"
                if [ $INSTALL_ZED_VERSION = "2.3" ] ; then
                    # Check which release of cuda has installed
                    if [ $(jetson_vercomp $JETSON_CUDA "9") -ge "0" ] ; then
                        JETSON_NAME+="_jp32"
                    elif [ $(jetson_vercomp $JETSON_CUDA "8") -ge "0" ] ; then
                        JETSON_NAME+="_jp31"
                    fi
                fi
            fi
            
            # Example output
            # https://download.stereolabs.com/zedsdk/2.7/tegraxavier

            tput setaf 6
            echo "Download https://download.stereolabs.com/zedsdk/$INSTALL_ZED_VERSION/$JETSON_NAME"
            tput sgr0
            
            # Local folder
            local LOCAL_FOLDER=$(pwd)
            # Move in temporary folder
            cd /tmp
            
            # Download ZED drivers
            wget --output-document zed_driver.run https://download.stereolabs.com/zedsdk/$INSTALL_ZED_VERSION/$JETSON_NAME
            
            # Set executable launcher
            chmod +x zed_driver.run
            
            # Launch zed_driver in silent mode
            ./zed_driver.run --quiet -- "silent"
            
            # Remove zed driver
            rm zed_driver.run
            
            # Restore previuous folder
            cd $LOCAL_FOLDER
        else
            tput setaf 1
            echo "I can't install the ZED drivers CUDA is not installed!"
            tput sgr0
        fi
    fi
}

script_load_default()
{
    if [ -z ${PKGS_PATCH_LIST+x} ] ; then
        # Empty packages patch list 
        PKGS_PATCH_LIST="\"\""
    fi
}

install_vs(){
    #Conflicts with node9, add code to remove node9 if user allows.
    echo "Install will include NodeJS 8 and Yarn"
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "Finished NodeJS install"
    wget https://dl.yarnpkg.com/debian/pubkey.gpg

    sudo apt-key add pubkey.gpg
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update
    sudo apt install yarn
    mkdir ~/VisualStudio
    cd ~/VisualStudio
    git clone https://github.com/microsoft/vscode
    cd vscode
    sudo rm package.json
    sudo rm test/smoke/package.json
    #clones the first pkg.json into the Vscode folder.
    git clone https://gist.github.com/e0010219e8af5e6cb4c4d34c35bba47d.git
    cd test/smoke/
    git clone https://gist.github.com/121e97781a56ae3e051335f77d2c600d.git
    cd ..
    cd ..
    yarn
    yarn run watch
    ./scripts/code.sh
    echo "Finished Install"
}

ros_install_rtabmap(){
    tput setaf 6
    echo "Installing RTABMAP enabled Zed SDK."
    tput sgr0
    #Purge existing RTABMAP with apt
    sudo apt-get remove ros-melodic-rtabmap
    #update sources
    sudo apt-get update
    #Install dependencies
    sudo apt-get install libsqlite3-dev libpcl-dev libopencv-dev git cmake libproj-dev libqt5svg5-dev
    mkdir ~/RTABMAP
    cd ~/RTABMAP
    #Install G2O
    git clone https://github.com/RainerKuemmerle/g2o.git 
    cd g2o
    mkdir build
    cd build
    #run CMAKE
    cmake -DBUILD_WITH_MARCH_NATIVE=OFF -DG2O_BUILD_APPS=OFF -DG2O_BUILD_EXAMPLES=OFF -DG2O_USE_OPENGL=OFF ..
    make -j4
    sudo make install
    #Finished insall of G2O
    #Install GTSAM
    cd ~/RTABMAP
    git clone --branch 4.0.0-alpha2 https://github.com/borglab/gtsam.git gtsam-4.0.0-alpha2
    cd gtsam-4.0.0-alpha2
    mkdir build
    cd build
    #run CMAKE 
    cmake -DGTSAM_USE_SYSTEM_EIGEN=ON -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF -DGTSAM_BUILD_TESTS=OFF -DGTSAM_BUILD_UNSTABLE=OFF ..
    make -j4
    sudo make install
    #End of GTSAM install

    #Install RTABMAP
    #Building from source will enable the Zed SDK and a few other important things.

    cd ~/RTABMAP
    git clone https://github.com/introlab/rtabmap.git rtabmap
    cd rtabmap/build
    cmake ..
    make -j4 
    sudo make install
}

script_save()
{    
    if [ ! -z ${PKGS_PATCH_LIST+x} ] ; then
        if [ $PKGS_PATCH_LIST != "\"\"" ]
        then
            echo "PKGS_PATCH_LIST=\"$PKGS_PATCH_LIST\"" >> $1
        fi
    fi
}

script_info()
{
    echo " - Will be add this packages: $PKGS_PATCH_LIST"
}

set_pkgs()
{
    if [ -z ${PKGS_PATCH_LIST+x} ]
    then
        # Empty kernel patch list
        PKGS_PATCH_LIST="\"\""
    fi
    
    local PKGS_PATCH_LIST_TMP
    PKGS_PATCH_LIST_TMP=$(whiptail --title "$MODULE_NAME" --checklist \
    "Which new packages do you want add?" 15 60 4 \
    "nano" "It is an easy-to-use text editor" $(pkgs_is_enabled "nano") \
    "htop" "Interactive processes viewer" $(pkgs_is_enabled "htop") \
    "iftop" "Network traffic viewer" $(pkgs_is_enabled "iftop") \
    "vs_oss" "Adds Visual Studio code to the Jetson" $(pkgs_is_enabled "vs_oss") \
    "synergy" "Adds Synergy for easy keyboard and mouse sharing" $(pkgs_is_enabled "synergy") \
    "guake" "Adds Guake terminal, easy to use dropdown menu." $(pkgs_is_enabled "guake") \
    "rtabmap" "Adds rtabmap with Zed SDK support" $(pkgs_is_enabled "rtabmap") \
    "ZED" "Install ZED driver version:$INSTALL_ZED_VERSION" $(pkgs_is_enabled "ZED") 3>&1 1>&2 2>&3)
     
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save list of new element to patch
        PKGS_PATCH_LIST="$PKGS_PATCH_LIST_TMP"
    fi
    
}
