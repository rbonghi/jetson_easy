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

# Following
# https://devtalk.nvidia.com/default/topic/1031736/jetson-tx2/cuda-9-0-samples-do-not-build-with-jetpack-3-2/

cuda_examples_check()
{
    if [ $JETSON_CUDA == "9.0" ] ; then
        return 1
    else
        return 0
    fi
}

patch_cuda_examples()
{
    cuda_examples_check
    if [ $? -eq 1 ] ; then
        if [ -d $HOME/NVIDIA_CUDA-9.0_Samples ] ; then
            sudo patch -p0 -N --dry-run --silent $HOME/NVIDIA_CUDA-9.0_Samples/6_Advanced/cdpLUDecomposition/Makefile cuda_examples/cuda_sample.patch 2>/dev/null
            #If the patch has not been applied then the $? which is the exit status 
            #for last command would have a success status code = 0
            if [ $? -eq 0 ];
            then
                #apply the patch
                tput setaf 6
                echo "Patching CUDA example in $HOME/NVIDIA_CUDA-9.0_Samples"
                tput sgr0
                sudo patch -N $HOME/NVIDIA_CUDA-9.0_Samples/6_Advanced/cdpLUDecomposition/Makefile cuda_examples/cuda_sample.patch
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
            
            sudo patch -p0 -N --dry-run --silent /usr/local/cuda-9.0/samples/6_Advanced/cdpLUDecomposition/Makefile cuda_examples/cuda_sample.patch 2>/dev/null
            #If the patch has not been applied then the $? which is the exit status 
            #for last command would have a success status code = 0
            if [ $? -eq 0 ];
            then
                #apply the patch
                tput setaf 6
                echo "Patching CUDA example in /usr/local/cuda-9.0/samples"
                tput sgr0
            
                sudo patch -N /usr/local/cuda-9.0/samples/6_Advanced/cdpLUDecomposition/Makefile cuda_examples/cuda_sample.patch
            else
                tput setaf 3
                echo "CUDA example in /usr/local/cuda-9.0/samples has already patched!"
                tput sgr0
            fi
        fi
    fi
}
