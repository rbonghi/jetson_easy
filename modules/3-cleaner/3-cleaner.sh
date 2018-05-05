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

# Clean Ubuntu distribution

MODULE_NAME="Clean Ubuntu distribution"
MODULE_DESCRIPTION="Clean the jetson from program futile:
Open Office
unity_scope"
MODULE_DEFAULT=0

MODULE_SUBMENU=("Remove packages:set_pkgs")

pkgs_remove_is_enabled()
{
    if [[ $PKGS_REMOVE_LIST = *"$1"* ]] ; then
        echo "ON"
    else
        echo "OFF"
    fi
}

uninstall_unity_scope()
{
    tput setaf 3
    echo "note:  to remove online search (wikipedia, amazon, ect.)"
    echo "       go to 'Security & Privacy' settings -> Search tab"
    echo "       and disable Online search"
    tput sgr0

    gsettings set com.canonical.Unity.Lenses disabled-scopes "['more_suggestions-amazon.scope', \
        'more_suggestions-u1ms.scope', 'more_suggestions-populartracks.scope', 'music-musicstore.scope', \
        'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']"

    sudo apt-get remove --purge unity-lens-friends -y
    sudo apt-get remove --purge unity-lens-music -y
    sudo apt-get remove --purge unity-lens-music -y
    sudo apt-get remove --purge unity-lens-photos -y
    sudo apt-get remove --purge unity-lens-video -y

    sudo apt-get remove --purge unity-scope-audacious -y
    sudo apt-get remove --purge unity-scope-calculator -y
    sudo apt-get remove --purge unity-scope-chromiumbookmarks -y
    sudo apt-get remove --purge unity-scope-clementine -y
    sudo apt-get remove --purge unity-scope-colourlovers -y
    sudo apt-get remove --purge unity-scope-devhelp -y
    sudo apt-get remove --purge unity-scope-firefoxbookmarks -y
    sudo apt-get remove --purge unity-scope-gdrive -y
    sudo apt-get remove --purge unity-scope-gmusicbrowser -y
    sudo apt-get remove --purge unity-scope-gourmet -y
    sudo apt-get remove --purge unity-scope-guayadeque -y
    sudo apt-get remove --purge unity-scope-manpages -y
    sudo apt-get remove --purge unity-scope-musicstores -y
    sudo apt-get remove --purge unity-scope-musique -y
    sudo apt-get remove --purge unity-scope-openclipart -y
    sudo apt-get remove --purge unity-scope-exdoc -y
    sudo apt-get remove --purge unity-scope-tomboy -y
    sudo apt-get remove --purge unity-scope-video-remote -y
    sudo apt-get remove --purge unity-scope-virtualbox -y
    sudo apt-get remove --purge unity-scope-yelp -y
    sudo apt-get remove --purge unity-scope-zotero -y
    
    sudo apt-get clean -y
    sudo apt-get autoremove -y
}

uninstall_libreoffice()
{
    # Remove the Libre Office installation
    # Useful if you need the extra rom
    sudo apt-get remove --purge libreoffice* -y
    sudo apt-get clean -y
    sudo apt-get autoremove -y
}

script_run()
{
    echo "Install standard packages"
    
    if [ $(pkgs_remove_is_enabled "libreoffice") == "ON" ] ; then
        tput setaf 6
        echo "Remove libreoffice"
        tput sgr0
        
        uninstall_libreoffice
    fi
    
    if [ $(pkgs_remove_is_enabled "unity_scope") == "ON" ] ; then
        tput setaf 6
        echo "Remove unity_scope"
        tput sgr0
        
        uninstall_unity_scope
    fi
}

script_load_default()
{
    if [ -z ${PKGS_REMOVE_LIST+x} ] ; then
        # Empty packages patch list 
        PKGS_REMOVE_LIST="libreoffice unity_scope"
    fi
}

script_save()
{    
    if [ ! -z ${PKGS_REMOVE_LIST+x} ] ; then
        if [ $PKGS_REMOVE_LIST != "\"\"" ]
        then
            echo "PKGS_REMOVE_LIST=\"$PKGS_REMOVE_LIST\"" >> $1
        fi
    fi
}

script_info()
{
    echo " - Will be removed this packages: $PKGS_REMOVE_LIST"
}

set_pkgs()
{
    script_load_default
    
    local PKGS_REMOVE_LIST_TMP
    PKGS_REMOVE_LIST_TMP=$(whiptail --title "$MODULE_NAME" --checklist \
    "Which new packages do you want remove?" 15 60 2 \
    "libreoffice" "It is an easy-to-use text editor" $(pkgs_remove_is_enabled "libreoffice") \
    "unity_scope" "Interactive processes viewer" $(pkgs_remove_is_enabled "unity_scope") 3>&1 1>&2 2>&3)
     
    local exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # Save list of new element to remove
        PKGS_REMOVE_LIST="$PKGS_REMOVE_LIST_TMP"
    fi
    
}
