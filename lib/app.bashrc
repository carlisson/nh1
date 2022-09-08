#!/bin/bash

# GLOBALS

_1APPLOCAL="$HOME/.nh1/apps"
_1APPLBIN="$HOME/bin"
_1APPGLOBAL="/opt/nh1/apps"
_1APPGBIN="/usr/local/bin"

# Generate partial menu
function _nh1app.menu {
  echo "___ Install AppImage ___"
  _1menuitem X 1app "List all available appimage"
  _1menuitem P 1appl "List all local appimage"
  _1menuitem P 1appg "List all global appimage"
  _1menuitem X 1applsetup "Configure your local path/dir"
  _1menuitem X 1appgsetup "Configure global path/dir"
  _1menuitem P 1appladd "Install an appimage locally"
  _1menuitem P 1appgadd "Install an appimage globaly"
  _1menuitem P 1applupd "Update a local appimage (or all)"
  _1menuitem P 1appgupd "Update a global appimage (or all)"
  _1menuitem P 1appldel "Remove a local appimage"
  _1menuitem P 1appgdel "Remove a global appimage"
  _1menuitem P 1applclear "Remove old versions for a local appimage (or all)"
  _1menuitem P 1appgclear "Remove old versions for a global appimage (or all)"
}

# Destroy all global variables created by this file
function _nh1app.clean {
  unset _1APPLOCAL _1APPLBIN _1APPGLOBAL _1APPGBIN
  unset -f _nh1app.menu _nh1app.clean 1applsetup 1appgsetup 1app \
    _nh1app.nextcloud
}

# Configure your local path/dir
function 1applsetup {
    mkdir -p "$_1APPLOCAL"
    mkdir -p "$_1APPLBIN"
    grep "$_1APPLBIN" "$HOME/.bashrc" 2>1 > /dev/null
    if [ $? -eq 0 ]
    then
        echo "1app may be installed. Check your .bashrc to confirm."
        echo "PATH shold include $_1APPLBIN"
    else
        echo "PATH=\"\$PATH:$_1APPLBIN\"" >> "$HOME/.bashrc"
        echo "1app configured"
    fi
}

# Configure your global path/dir
function 1appgsetup {
    if [ "$EUID" -eq 0 ]
    then
        mkdir -p "$_1APPGLOBAL"
    else
        sudo mkdir -p "$_1APPGLOBAL"
    fi
    echo "1app installed."
}

# List all available app image for installation
function 1app {
  echo "___ 1app available ___"
  _1menuitem P nextcloud "Nextcloud client"
}

# Nextcloud downloader
# @param app-directory
# @param symlink
# @param sudo? 0=yes; 1=no
function _nh1app.nextcloud {
    _NADIR="$1"
    _NASYM="$2/nextcloud"
    _NAS=$3
    _NANEW=$(curl -s https://nextcloud.com/install/ | tr '\n' ' ' | \
        sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/' | \
        sed 's/\(.*\)\///g')
    if [ -f "$_NADIR/$_NANEW" ]
    then
        echo "Nextcloud is already up to date."
    else
        pushd $_NADIR
        if [ $_NAS -eq 0 ]
        then
            sudo wget -c "$(curl -s https://nextcloud.com/install/ | tr '\n' ' ' | sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/')"
        else
            wget -c "$(curl -s https://nextcloud.com/install/ | tr '\n' ' ' | sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/')"
        fi
        popd
        if [ -L "$_NASYM" ]
        then
            if [ $_NAS -eq 0 ]
            then
                sudo rm "$_NASYM"
            else
                rm "$_NASYM"
            fi
        fi
        if [ $_NAS -eq 0 ]
        then
            sudo ln -s "$_NADIR/$_NANEW" "$_NASYM"
        else
            ln -s "$_NADIR/$_NANEW" "$_NASYM"
        fi
    fi
}
