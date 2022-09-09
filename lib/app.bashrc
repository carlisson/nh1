#!/bin/bash

# GLOBALS

_1APPLOCAL="$_1UDATA/apps"
_1APPLBIN="$HOME/bin"
_1APPGLOBAL="$_1GDATA/apps"
_1APPGBIN="/usr/local/bin"

# Generate partial menu
function _nh1app.menu {
  echo "___ Install AppImage ___"
  _1menuitem X 1app "List all available appimage"
  _1menuitem P 1appl "List all local appimage"
  _1menuitem P 1appg "List all global appimage"
  _1menuitem X 1applsetup "Configure your local path/dir"
  _1menuitem X 1appgsetup "Configure global path/dir"
  _1menuitem X 1appladd "Install an appimage locally"
  _1menuitem X 1appgadd "Install an appimage globaly"
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
    _nh1app.nextcloud _nh1app.add 1appladd 1appgadd _nh1app.nextcloud.version
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
  _1menuitem P funcoeszz "Funções ZZ - A set of shell utils."
  _1menuitem X nextcloud "Nextcloud client"
  _1menuitem P onlyoffice "OnlyOffice desktop edition"
}

# Return newest Nextcloud file version or actual
# @param new, local or global
function _nh1app.nextcloud.version {
    case "$1" in
        new)
            curl -s https://nextcloud.com/install/ | tr '\n' ' ' | \
            sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/' | \
            sed 's/\(.*\)\///g'
            ;;
        local)
            if [ -L "$_1APPLBIN/nextcloud" ]
            then
                basename -z $(readlink "$_1APPLBIN/nextcloud")
            fi
            ;;
        global)
            if [ -L "$_1APPGBIN/nextcloud" ]
            then
                basename -z $(readlink "$_1APPGBIN/nextcloud") | echo -n
            fi
            ;;
    esac
}

# Nextcloud downloader
# @param app-directory
# @param symlink
# @param sudo? 0=yes; 1=no
function _nh1app.nextcloud {
    if 1check curl
    then
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
                sudo curl -O -L "$(curl -s https://nextcloud.com/install/ | tr '\n' ' ' | sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/')"
                sudo chmod a+x "$_NANEW"
            else
                curl -O -L "$(curl -s https://nextcloud.com/install/ | tr '\n' ' ' | sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/')"
                chmod a+x "$_NANEW"
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
    fi
}

# Internal 1app generic installer
# @param local or global
# @param app to install
function _nh1app.add {
    if [ "$1" = "global" ]
    then
        _NAD=$_1APPGLOBAL
        _NAB=$_1APPGBIN
        _NAS=0
    else
        _NAD=$_1APPLOCAL
        _NAB=$_1APPLBIN
        _NAS=1
    fi
    case "$2" in
        nextcloud)
            _nh1app.nextcloud "$_NAD" "$_NAB" "$_NAS"
            ;;
        *)
            echo "Unknown app: $2"
            ;;
    esac
}


# Install locally an app
# @param App to install
function 1appladd {
    for _NAA in "$@"
    do
        _nh1app.add local "$_NAA"
    done
}

# Install globally an app
# @param App to install
function 1appgadd {
    for _NAA in "$@"
    do
        _nh1app.add global "$_NAA"
    done
}


