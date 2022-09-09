#!/bin/bash

# GLOBALS

_1APPLOCAL="$_1UDATA/apps"
_1APPLBIN="$HOME/bin"
_1APPGLOBAL="$_1GDATA/apps"
_1APPGBIN="/usr/local/bin"
_1APPAVAIL="nextcloud"

# Generate partial menu
function _nh1app.menu {
  echo "___ Install App ___"
  _1menuitem X 1app "List all available apps"
  _1menuitem X 1appl "List all local apps"
  _1menuitem X 1appg "List all global apps"
  _1menuitem X 1applsetup "Configure your local path/dir"
  _1menuitem X 1appgsetup "Configure global path/dir"
  _1menuitem X 1appladd "Install or update an app locally"
  _1menuitem X 1appgadd "Install or update an app globaly"
  _1menuitem X 1applupd "Update all local apps"
  _1menuitem X 1appgupd "Update all global apps"
  _1menuitem P 1appldel "Remove a local app"
  _1menuitem P 1appgdel "Remove a global app"
  _1menuitem P 1applclear "Remove old versions for a local app (or all)"
  _1menuitem P 1appgclear "Remove old versions for a global app (or all)"
}

# Destroy all global variables created by this file
function _nh1app.clean {
  unset _1APPLOCAL _1APPLBIN _1APPGLOBAL _1APPGBIN 1appl 1appg 1applupd 1appgupd
  unset -f _nh1app.menu _nh1app.clean 1applsetup 1appgsetup 1app \
    _nh1app.nextcloud _nh1app.add 1appladd 1appgadd _nh1app.checkversion \
    _nh1app.list
}

alias 1appl="_nh1app.list local"
alias 1appg="_nh1app.list global"
alias 1applupd="_nh1app.update local"
alias 1appgupd="_nh1app.update global"

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
# @param app name
# @param new, local or global
function _nh1app.checkversion {
    case "$2" in
        new)
            case "$1" in
                nextcloud)
                    curl -s https://nextcloud.com/install/ | tr '\n' ' ' | \
                    sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/' | \
                    sed 's/\(.*\)\///g'
                    ;;
            esac
            ;;
        local)
            if [ -L "$_1APPLBIN/$1" ]
            then
                basename $(readlink "$_1APPLBIN/$1")
            fi
            ;;
        global)
            if [ -L "$_1APPGBIN/$1" ]
            then
                basename $(readlink "$_1APPGBIN/$1")
            fi
            ;;
    esac
}

# Nextcloud downloader
# @param app-directory
# @param symlink
# @param sudo? 0=yes; 1=no
function _nh1app.nextcloud {
    local _NADIR _NASYM _NAS _NANEW
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
    local _NAD _NAB _NAS
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
    local _NAA
    for _NAA in "$@"
    do
        _nh1app.add local "$_NAA"
    done
}

# Install globally an app
# @param App to install
function 1appgadd {
    local _NAA
    for _NAA in "$@"
    do
        _nh1app.add global "$_NAA"
    done
}

# List all installed apps
# @param local or global
function _nh1app.list {
   local _NAA _NAAC
   echo "___ Installed Apps ($1) ___"
   for _NAA in $_1APPAVAIL
    do
        _NAAC=$(_nh1app.checkversion $_NAA $1)
        if [ -n "$_NAAC" ]
        then
            1tint 6 "$_NAA"
            echo -en '\t'
            echo $_NAAC
        fi
    done
}

# Update all installed apps
# @param local or global
function _nh1app.update {
    local _NAA _NAAC
    for _NAA in $_1APPAVAIL
    do
        _NAAC=$(_nh1app.checkversion $_NAA $1)
        if [ -n "$_NAAC" ]
        then
            if [ "$1" = "local" ]
            then
                1appladd "$_NAA"
            else
                1appgadd "$_NAA"
            fi
        fi
    done   
}