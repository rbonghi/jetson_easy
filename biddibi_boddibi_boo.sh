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

TEXT_RESET='\e[0m'
TEXT_GREEN='\e[0;32m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'

# Load environment variables:
# - DISTRIB_ID
# - DISTRIB_RELEASE
# - DISTRIB_CODENAME
# - DISTRIB_DESCRIPTION
source /etc/lsb-release

# Load architecture
ARCHITECTURE=$(uname -m)

# NVIDIA Identify version 
# reference: https://devtalk.nvidia.com/default/topic/1014424/jetson-tx2/identifying-tx1-and-tx2-at-runtime/
case $(cat /sys/module/tegra_fuse/parameters/tegra_chip_id) in
    64)
        JETSON_BOARD="TK1"
    33)
        JETSON_BOARD="TX1"
    24)
        JETSON_BOARD="TX2"
    *)
        JETSON_BOARD="UNKNOWN"
esac
# NVIDIA Jetson version
JETSON_VER=$(head -n 1 /etc/nv_tegra_release)

# Update embedded board
echo -e $TEXT_GREEN
echo "|-----------------------------------------------------------------------|"
echo "| Welcome in the Biddibi Boddibi boo robot embedded board initialzation |"
echo "|-----------------------------------------------------------------------|"
echo ""
echo "System information:"
echo " - System version: $DISTRIB_DESCRIPTION"
echo " - Architecture: $ARCHITECTURE"
echo " - NVIDIA Jetson information:"
echo "   - Board: $JETSON_BOARD"
echo "   - version: $JETSON_VER"
echo " - User: $USER"

# TODO show:
# - Jetpack version
# - Architecture
# - Type of board

# Installing order script:
# - update & dist-upgrade & upgrade
# - Set hostname
# - Install ROS
# - Install USB and ACM driver

echo -e $TEXT_RESET

read -p "Do you want continue? [Y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi
# ------------------------------------
# - update & dist-upgrade & upgrade

sudo apt-get update
echo -e $TEXT_YELLOW
echo 'APT update finished...'
echo -e $TEXT_RESET

# Automatically upgrade all packages
sudo apt-get -y dist-upgrade
echo -e $TEXT_YELLOW
echo 'APT distributive upgrade finished...'
echo -e $TEXT_RESET

# Automatically upgrade all packages
sudo apt-get -y upgrade
echo -e $TEXT_YELLOW
echo 'APT upgrade finished...'
echo -e $TEXT_RESET

# Automatically remove packages
sudo apt-get -y autoremove
echo -e $TEXT_YELLOW
echo 'APT auto remove finished...'
echo -e $TEXT_RESET

# ------------------------------------
echo -e $TEXT_GREEN
echo "|-----------------------------------------------------------------------|"
echo "| Setup HOSTNAME                                                        |"
echo "|-----------------------------------------------------------------------|"
echo -e $TEXT_RESET


read -p "Press any key to continue... " -n1 -s

# ------------------------------------
echo -e $TEXT_GREEN
echo "|-----------------------------------------------------------------------|"
echo "| Installing ROS                                                        |"
echo "|-----------------------------------------------------------------------|"
echo -e $TEXT_RESET



if [ -f /var/run/reboot-required ]; then
    echo -e $TEXT_RED_B
    echo 'Reboot required!'
    echo -e $TEXT_RESET
fi

echo "END!"
