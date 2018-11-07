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
