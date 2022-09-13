#!/bin/bash

# GLOBALS

_1APPLOCAL="$_1UDATA/apps"
_1APPLBIN="$HOME/bin"
_1APPGLOBAL="$_1GDATA/apps"
_1APPGBIN="/usr/local/bin"
_1APPAVAIL="funcoeszz nextcloud"

# Generate partial menu
function _nh1app.menu {
  echo "___ Install App ___"
  _1menuitem X 1app "List all available apps"
  _1menuitem X 1appladd "Install or update an app locally"
  _1menuitem X 1appgadd "Install or update an app globaly"
  _1menuitem X 1applupd "Update all local apps"
  _1menuitem X 1appgupd "Update all global apps"
  _1menuitem X 1appldel "Remove a local app"
  _1menuitem X 1appgdel "Remove a global app"
  _1menuitem X 1applclear "Remove old versions for a local app (or all)"
  _1menuitem X 1appgclear "Remove old versions for a global app (or all)"
}

# Destroy all global variables created by this file
function _nh1app.clean {
  unset _1APPLOCAL _1APPLBIN _1APPGLOBAL _1APPGBIN 1applupd
  unset 1appgupd 1appldel 1appgdel 1applclear 1appgclear
  unset -f _nh1app.menu _nh1app.clean _nh1app.setup 1app
  unset -f _nh1app.nextcloud _nh1app.add 1appladd 1appgadd 
  unset -f _nh1app.checkversion _nh1app.list _nh1app.remove 
  unset -f _nh1app.checksetup _nh1app.description _nh1app.clear
}

alias 1applupd="_nh1app.update local"
alias 1appgupd="_nh1app.update global"
alias 1appldel="_nh1app.remove local"
alias 1appgdel="_nh1app.remove global"
alias 1applclear="_nh1app.clear local"
alias 1appgclear="_nh1app.clear global"

# Configure your local or global path/dir
# @param local or global
function _nh1app.setup {
    if [ "$1" = "local" ]
    then
        mkdir -p "$_1APPLOCAL"
        mkdir -p "$_1APPLBIN"
        grep "$_1APPLBIN" "$HOME/.bashrc" 2>1 > /dev/null
        if [ $? -ne 0 ]
        then
            echo "PATH=\"\$PATH:$_1APPLBIN\"" >> "$HOME/.bashrc"
        fi
    else
        _1sudo mkdir -p "$_1APPGLOBAL"
    fi
}

# Check if setup is ok
# @param local or global
function _nh1app.checksetup {
    if [ "$1" = "local" ]
    then
        if [ -d "$_1APPLOCAL" ]
        then
            return 0
        else
            return 1
        fi
    else
        if [ -d "$_1APPGLOBAL" ]
        then
            return 0
        else
            return 1
        fi
    fi
}

# List all available app image for installation
function 1app {
    local _NAA _NAS _NAU _NAC
    echo "___ 1app status ___"
    echo -e 'App\t\tDescription\t\t\tInstallation'
    for _NAA in $_1APPAVAIL
    do
        echo -n $_NAA
        echo -en '\t'
        _nh1app.description "$_NAA"
        echo -en '\t'
        _NAC=0
        _NAU=$(_nh1app.checkversion local "$_NAA")
        if [ -n "$_NAU" ]
        then
            1tint 6 "local"
            echo -en '\t'
            _NAC=$((_NAC+1))
        fi
        _NAU=$(_nh1app.checkversion global "$_NAA")
        if [ -n "$_NAU" ]
        then
            1tint 6 "global"
            echo -en '\t'
            _NAC=$((_NAC+1))
        fi
        if [ "$_NAC" -eq 0 ]
        then
            echo -n 'None'
        fi
        echo
    done
    echo "___ Usage ___"
    1tint 2 1appladd
    echo -n " to install locally and "
    1tint 1 1appldel
    echo " to uninstall."
    1tint 2 1appgadd
    echo -n " to install globally and "
    1tint 1 1appgdel
    echo " to uninstall."
}

# Return description for an available app
# @param App name
function _nh1app.description {
    case "$1" in
        funcoeszz)
            echo -ne 'A set of shell utils.\t'
            ;;
        nextcloud)
            echo -ne 'Nextcloud desktop client'
            ;;
        onlyoffice)
            echo -ne 'OnlyOffice desktop edition'
            ;;
    esac
}

# Return newest Nextcloud file version or actual
# @param new, local or global
# @param app name
function _nh1app.checkversion {
    case "$1" in
        new)
            case "$2" in
                nextcloud)
                    curl -s https://nextcloud.com/install/ | tr '\n' ' ' | \
                    sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/' | \
                    sed 's/\(.*\)\///g'
                    ;;
                funcoeszz)
                    curl -s http://funcoeszz.net/download/ | tr '\n' ' ' | \
                    sed 's/\(.*\)\/download\/\(funcoeszz-\(.*\).sh\)\(.*\)/\2/' | \
                    sed 's/"\(.*\)//g'
                    ;;
            esac
            ;;
        local)
            if [ -L "$_1APPLBIN/$2" ]
            then
                basename $(readlink "$_1APPLBIN/$2")
            fi
            ;;
        global)
            if [ -L "$_1APPGBIN/$2" ]
            then
                basename $(readlink "$_1APPGBIN/$2")
            fi
            ;;
    esac
}

# Nextcloud downloader
# @param app-directory
# @param symlink
# @param local or global
function _nh1app.nextcloud {
    local _NADIR _NASYM _NAS _NANEW
    if 1check curl
    then
        _NADIR="$1"
        _NASYM="$2/nextcloud"
        _NAS=$3
        _NANEW=$(_nh1app.checkversion new nextcloud)
        if [ -f "$_NADIR/$_NANEW" ]
        then
            echo "Nextcloud is already up to date."
        else
            pushd $_NADIR
            if [ $_NAS = "global" ]
            then
            
                _1sudo curl -O -L "$(curl -s https://nextcloud.com/install/ | tr '\n' ' ' | sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/')"
                _1sudo chmod a+x "$_NANEW"
            else
                curl -O -L "$(curl -s https://nextcloud.com/install/ | tr '\n' ' ' | sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/')"
                chmod a+x "$_NANEW"
            fi
            popd
            if [ -L "$_NASYM" ]
            then
                if [ $_NAS = "global" ]
                then
                    _1sudo rm "$_NASYM"
                else
                    rm "$_NASYM"
                fi
            fi
            if [ $_NAS = "global" ]
            then
                _1sudo ln -s "$_NADIR/$_NANEW" "$_NASYM"
            else
                ln -s "$_NADIR/$_NANEW" "$_NASYM"
            fi
        fi
    fi
}

# funcoeszz downloader
# @param app-directory
# @param symlink
# @param local or global
function _nh1app.funcoeszz {
    local _NADIR _NASYM _NAS _NANEW
    if 1check curl
    then
        _NADIR="$1"
        _NASYM="$2/funcoeszz"
        _NAS=$3
        _NANEW=$(_nh1app.checkversion new funcoeszz)
        if [ -f "$_NADIR/$_NANEW" ]
        then
            echo "funcoeszz is already up to date."
        else
            pushd $_NADIR
            if [ $_NAS = "global" ]
            then
                _1sudo curl -O -L "http://funcoeszz.net/download/$_NANEW"
                _1sudo chmod a+x "$_NANEW"
            else
                curl -O -L "http://funcoeszz.net/download/$_NANEW"
                chmod a+x "$_NANEW"
            fi
            popd
            if [ -L "$_NASYM" ]
            then
                if [ $_NAS = "global" ]
                then
                    _1sudo rm "$_NASYM"
                else
                    rm "$_NASYM"
                fi
            fi
            if [ $_NAS = "global" ]
            then
                _1sudo ln -s "$_NADIR/$_NANEW" "$_NASYM"
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
    if ! $(_nh1app.checksetup $1)
    then
        _nh1app.setup $1
    fi
    _NAS=$1
    if [ "$1" = "global" ]
    then
        _NAD=$_1APPGLOBAL
        _NAB=$_1APPGBIN
    else
        _NAD=$_1APPLOCAL
        _NAB=$_1APPLBIN
    fi
    case "$2" in
        funcoeszz)
            _nh1app.funcoeszz "$_NAD" "$_NAB" "$_NAS"
            ;;
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
        _NAAC=$(_nh1app.checkversion $1 $_NAA)
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
        _NAAC=$(_nh1app.checkversion $1 $_NAA)
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

# Remove an installed app
# @param local or global 
# @param app name
function _nh1app.remove {
    local _NAA _NAF
    _NAA=$2
    _NAF=$(_nh1app.checkversion $1 $_NAA)
    if [ -n "$_NAF" ]
    then
        case "$_NAA" in
            funcoeszz|nextcloud)
                if [ "$1" = "local" ]
                then
                    rm "$_1APPLOCAL/$_NAF"
                    rm "$_1APPLBIN/$_NAA"
                else
                    _1sudo rm "$_1APPGLOBAL/$_NAF"
                    _1sudo rm "$_1APPGBIN/$_NAA"
                fi
                ;;
        esac
    fi
}

# Clear unused old versions for every app
# @param local or global
function _nh1app.clear {
    local _NAA _NAN _NAF _NAD
    if [ $1 = "local" ]
    then
        _NAD=$_1APPLOCAL
    else
        _NAD=$_1APPGLOBAL
    fi
    for _NAA in "$_1APPAVAIL"
    do
        _NAN=$(_nh1app.checkversion "$1" "$_NAA")
        case "$_NAA" in
            funcoeszz)
                for _NAF in $(ls $_NAD/funcoeszz-* 2>/dev/null)
                do
                    if [ "$_NAN" != $(basename "$_NAF") ]
                    then
                        if [ "$1" = "global" ]
                        then
                            _1sudo rm "$_NAF"
                        else
                            rm "$_NAF"
                        fi
                    fi
                done
                ;;
            nextcloud)
                for _NAF in $(ls $_NAD/Nextcloud* 2>/dev/null)
                do
                    if [ "$_NAN" != $(basename "$_NAF") ]
                    then
                        if [ "$1" = "global" ]
                        then
                            _1sudo rm "$_NAF"
                        else
                            rm "$_NAF"
                        fi
                    fi
                done
                ;;
        esac
    done
}
