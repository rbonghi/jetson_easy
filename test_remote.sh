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

# https://zaiste.net/posts/a_few_ways_to_execute_commands_remotely_using_ssh/
# https://www.cyberciti.biz/faq/linux-unix-applesox-ssh-password-on-command-line/

USER=nvidia
PASSWORD=nvidia
HOST=tegra-ubuntu.local

load_to_host()
{
    HOST=$1
    USER=$2
    PASSWORD=$3

    local CHECK=0
    
    while [ $CHECK != 1 ] ; do
        sshpass -p "$PASSWORD" ssh $USER@$HOST '
            if [ -d /tmp/jetson_easy ] ; then
                exit 0
            else
                exit 1
            fi   
        '
        case $? in
            0) echo "Remove old folder"
               sshpass -p "$PASSWORD" ssh $USER@$HOST rm -r /tmp/jetson_easy
               ;;
            1) echo "Copy this folder"
               sshpass -p "$PASSWORD" scp -r . $USER@$HOST:/tmp/jetson_easy
               CHECK=1
               ;;
            *) ;;
        esac
    done
}

# Load to host all scripts
load_to_host $HOST $USER $PASSWORD

# execute function
sshpass -p "$PASSWORD" ssh $USER@$HOST 'bash -s' < include/remote.sh $HOST $USER $PASSWORD


#if [ $? == 1 ] ; then
#    echo "Copy this folder"
#    sshpass -p "$PASSWORD" scp -r . $USER@$HOST:/tmp/jetson_easy
#fi

#sshpass -p "$PASSWORD" ssh $USER@$HOST bash -c "'pwd ; echo $HOST'"

#tar -zcf jetson_easy.tar.gz jetson

#sshpass -p "$PASSWORD" ssh -t $USER@$HOST << EOF
#cd jetson_easy
#./biddibi_boddibi_boo.sh
#if [ ! -d jetson_easy ] ; then  #check existence of the file
#echo "folder is present"
#scp -r . $USER@$HOST:/tmp/test
#fi
#if [ \$? -eq 0 ] ; then
#     echo "Command was successful."
#else
#   echo "An error was encountered."
#   exit
#fi
#EOF
#exit


#echo "read from Jetson"

#sshpass -p "$PASSWORD" scp jetson_easy.tar.gz $USER@$HOST:/tmp

#sshpass -p "$PASSWORD" scp -r . $USER@$HOST:/tmp/test

#scp -r directory_to_copy user@remote.server.fi:/path/to/location

# sshpass -p "$PASSWORD" ssh -t $USER@$HOST jetson_release

#sshpass -p "$PASSWORD" ssh -t $USER@$HOST '
#cd jetson_easy
#
#source jetson/jetson_variables
#
#echo "$JETSON_L4T"
#
#./biddibi_boddibi_boo.sh
#
#'
