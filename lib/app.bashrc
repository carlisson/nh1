#!/bin/bash

# GLOBALS

_1APPLOCAL="$_1UDATA/apps"
_1APPLBIN="$HOME/bin"
_1APPGLOBAL="$_1GDATA/apps"
_1APPGBIN="/usr/local/bin"
_1APPLIB="$_1LIB/recipes"
_1APPLAPPS="$HOME/.local/share/applications"
_1APPGAPPS="/usr/share/applications"
_1APPLICON="$HOME/.local/share/icons"
_1APPGICON="/usr/share/icons"

# Generate partial menu
function _nh1app.menu {
  echo "___ $(_1text "Install App") ___"
  _1menuitem X 1app "$(_1text "List all available apps")"
  _1menuitem X 1appladd "$(_1text "Install or update an app locally")"
  _1menuitem X 1appgadd "$(_1text "Install or update an app globaly")"
  _1menuitem X 1applupd "$(_1text "Update all local apps")"
  _1menuitem X 1appgupd "$(_1text "Update all global apps")"
  _1menuitem X 1appxupd "$(_1text "Upgrade all packages(using OS)")"
  _1menuitem X 1appldel "$(_1text "Remove a local app")"
  _1menuitem X 1appgdel "$(_1text "Remove a global app")"
  _1menuitem X 1applclear "$(_1text "Remove old versions for a local app (or all)")"
  _1menuitem X 1appgclear "$(_1text "Remove old versions for a global app (or all)")"
}

# Destroy all global variables created by this file
function _nh1app.clean {
  unset _1APPLOCAL _1APPLBIN _1APPGLOBAL _1APPGBIN _1APPLIB
  unset -f _nh1app.menu _nh1app.clean _nh1app.setup 1app
  unset -f _nh1app.single _nh1app.add 1appladd 1appgadd 
  unset -f _nh1app.checkversion _nh1app.list _nh1app.remove 
  unset -f _nh1app.checksetup _nh1app.description _nh1app.clear
  unset -f _nh1app.openapp _nh1app.closeapp _nh1app.avail
  unset -f 1applupd 1appgupd 1appldel 1appgdel 1applclear 1appgclear
  unset -f 1appxupd _nh1app.where _nh1app.complete
}

# Alias-like
function 1applupd   { _nh1app.update local ; }
function 1appgupd   { _nh1app.update global ; }
function 1appldel   { _nh1app.remove local "$1"; }
function 1appgdel   { _nh1app.remove global "$1"; }
function 1applclear { _nh1app.clear local ; }
function 1appgclear { _nh1app.clear global ; }

function _nh1app.complete {
    _1verb "Enabling complete for 1app."
    complete -W "$(_nh1app.list local 0)" 1appladd
    complete -W "$(_nh1app.list global 0)" 1appgadd
    complete -W "$(_nh1app.list local 1)" 1appldel
    complete -W "$(_nh1app.list global 1)" 1appgdel
}

function _nh1app.avail {
    pushd $_1APPLIB > /dev/null
    ls *.app | sed 's/.app//g' | tr '\n' ' '
    popd -n > /dev/null
}

# Configure your local or global path/dir
# @param local or global
function _nh1app.setup {
    if [ "$1" = "local" ]
    then
        mkdir -p "$_1APPLOCAL"
        mkdir -p "$_1APPLBIN"
        mkdir -p "$_1APPLAPPS"
        mkdir -p "$_1APPLICON"
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
    echo "___ $(_1text "1app status") ___"
    printf "%-15s %-45s%s\n" "$(_1text App)" "$(_1text Description)" "$(_1text Installation)"
    for _NAA in $(_nh1app.avail)
    do
        printf "%-15s %-45s" "$_NAA" "$(_nh1app.description $_NAA)"
        #echo -n $_NAA
        #echo -en '\t'
        #_nh1app.description "$_NAA"
        #echo -en '\t'
        _NAC=0
        _NAU=$(_nh1app.checkversion local "$_NAA")
        if [ -n "$_NAU" ]
        then
            1tint 6 "$(_1text local)"
            echo -en '\t'
            _NAC=$((_NAC+1))
        fi
        _NAU=$(_nh1app.checkversion global "$_NAA")
        if [ -n "$_NAU" ]
        then
            1tint 6 "$(_1text global)"
            echo -en '\t'
            _NAC=$((_NAC+1))
        fi
        if [ "$_NAC" -eq 0 ]
        then
            echo -n "$(_1text None)"
        fi
        echo
    done
    echo "___ $(_1text Usage) ___"
    1tint 2 1appladd
    echo -n "$(_1text " to install locally and ")"
    1tint 1 1appldel
    echo "$(_1text " to uninstall.")"
    1tint 2 1appgadd
    echo -n "$(_1text " to install globally and ")"
    1tint 1 1appgdel
    echo "$(_1text " to uninstall.")"
}

# Open app description
# @param app name
function _nh1app.openapp {
    if [ -f "$_1APPLIB/$1.app" ]
    then
        source "$_1APPLIB/$1.app"
        return 0
    else
        return 1
    fi
}

# Close app description
function _nh1app.closeapp {
  unset APP_DESCRIPTION APP_TYPE APP_BINARY APP_DEPENDS APP_PREFIX
  unset -f APP_POSTINST APP_VERSION APP_GET
}

# Return description for an available app
# @param App name
function _nh1app.description {
    if _nh1app.openapp $1
    then
        echo -n $APP_DESCRIPTION
        _nh1app.closeapp
    else
        echo -n "???"
    fi
}

# Return newest Nextcloud file version or actual
# @param new, local or global
# @param app name
function _nh1app.checkversion {
    if _nh1app.openapp $2
    then
        case "$1" in
            new)
                APP_VERSION                
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
        _nh1app.closeapp
    fi
}

# Single downloader
# @param app name
# @param app-directory
# @param symlink
# @param local or global
function _nh1app.single {
    local _NAPP _NADIR _NASYM _NAS _NANEW _NATMP
    if 1check curl
    then
        _NAPP="$1"
        _NADIR="$2"
        _NASYM="$3/$1"
        _NAS=$4
        _NANEW=$(_nh1app.checkversion new $_NAPP)
        if [ -f "$_NADIR/$_NANEW" ]
        then
            printf "$(_1text "%s is already up to date.")\n" $_NAPP
        else
            pushd $_NADIR
            if _nh1app.openapp $_NAPP
            then
                if [ $_NAS = "global" ]
                then
                    APP_GET sudo
                    _1sudo chmod a+x "$_NANEW"
                    if [ -f "$_1APPLIB/$_NAPP.desktop" ]
                    then
                        _NATMP=$(mktemp)
                        cp "$_1APPLIB/$_NAPP.desktop" "$_NATMP"
                        echo "Exec=$_NASYM" >> "$_NATMP"
                        if [ -f "$_1APPLIB/$_NAPP.png" ]
                        then
                            _1sudo cp "$_1APPLIB/$_NAPP.png" "$_1APPGICON/"
                            echo "Icon=$_1APPGICON/$_NAPP.png" >> "$_NATMP"
                        fi
                        _1sudo cp "$_NATMP" "$_1APPGAPPS/$_NAPP.desktop"
                        _1sudo chmod a+r "$_1APPGAPPS/$_NAPP.desktop"
                        rm "$_NATMP"
                    fi
                else
                    APP_GET
                    chmod a+x "$_NANEW"
                    if [ -f "$_1APPLIB/$_NAPP.desktop" ]
                    then
                        cp "$_1APPLIB/$_NAPP.desktop" "$_1APPLAPPS/"
                        echo "Exec=$_NASYM" >> "$_1APPLAPPS/$_NAPP.desktop"
                        if [ -f "$_1APPLIB/$_NAPP.png" ]
                        then
                            cp "$_1APPLIB/$_NAPP.png" "$_1APPLICON/"
                            echo "Icon=$_1APPLICON/$_NAPP.png" >> "$_1APPLAPPS/$_NAPP.desktop" 
                        fi
                    fi
                fi
                _nh1app.closeapp
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
    local _NAD _NAB _NAS _NAT
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
 
    if _nh1app.openapp $2
    then
        _NAT="$APP_TYPE"
        _nh1app.closeapp
        case "$_NAT" in
            single)
                 _nh1app.single "$2" "$_NAD" "$_NAB" "$_NAS"
                 ;;
            *)
                printf "$(_1text "Type unsuported: %s.")\n" $_NAT
            esac
    else
        echo "$(_1text "Unknown app: %s.")" $2
    fi
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

# Based on avail, list apps with filters
# @param local or global
# @param installed (1) or not-installed (0)
function _nh1app.list {
    local _A _OUT _CHK
    for _A in $(_nh1app.avail)
    do
        _CHK=$(_nh1app.checkversion "$1" "$_A")
        if [ $2 -eq 1 ] && [ -n "$_CHK" ]
        then
            _OUT="$_OUT $_A"
        elif [ $2 -eq 0 ] && [ -z "$_CHK" ]
        then
            _OUT="$_OUT $_A"
        fi
    done
    echo $_OUT
}


# Update all installed apps
# @param local or global
function _nh1app.update {
    local _NAA _NAAC
    for _NAA in $(_nh1app.avail)
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

# Returns full path for a command, if exists
# @param app to test
function _nh1app.where {
    local _AUX _PATH
    _AUX=$(whereis "$1")
    _PATH=$(echo "$_AUX" | cut -d\  -f 2)
    if [ "$_PATH" = "$_AUX" ]
    then
        return 1
    else
        echo $_PATH
        return 0
    fi
}

# Upgrade all packages
function 1appxupd {
    local _UPD
        
    if _nh1app.where dnf > /dev/null
    then
        printf "$(_1text "Upgrading %s...")\n" dnf
        _1sudo dnf update
    fi

    if _nh1app.where apt > /dev/null
    then
        printf "$(_1text "Upgrading %s...")\n" apt
        _1sudo apt update
        _1sudo apt upgrade
        _1sudo apt clean
    fi

    if _nh1app.where zypper > /dev/null
    then
        printf "$(_1text "Upgrading %s...")\n" zypper
        _1sudo zypper ref
        _1sudo zypper update
    fi

    if _nh1app.where pacman > /dev/null
    then
        printf "$(_1text "Upgrading %s...")\n" pacman
        _1sudo pacman -Syu
    fi

    if _nh1app.where snap > /dev/null
    then
        printf "$(_1text "Upgrading %s...")\n" snap
        _1sudo snap refresh
    fi

    if _nh1app.where flatpak > /dev/null
    then
        printf "$(_1text "Upgrading %s...")\n" flatpak
        _1sudo flatpak update
    fi
}

# Remove an installed app
# @param local or global 
# @param app name
function _nh1app.remove {
    local _NAA _NAF
    _NAA=$2
    _NAF=$(_nh1app.checkversion $1 $_NAA)
    _1verb "$(printf "$(_1text "App %s installed with file %s")" $_NAA $_NAF)"
    if [ -n "$_NAF" ]
    then
        if [ "$1" = "local" ]
        then
            rm "$_1APPLOCAL/$_NAF"
            rm "$_1APPLBIN/$_NAA"
            rm -f "$_1APPLAPPS/$_NAA.desktop"
            rm -f "$_1APPLICON/$_NAA.png"
        else
            _1sudo rm "$_1APPGLOBAL/$_NAF"
            _1sudo rm "$_1APPGBIN/$_NAA"
            _1sudo rm -f "$_1APPGAPPS/$_NAA.desktop"
            _1sudo rm -f "$_1APPLICON/$_NAA.png"
        fi
    fi
}

# Clear unused old versions for every app
# @param local or global
function _nh1app.clear {
    local _NAA _NAN _NAF _NAD _NAP
    if [ $1 = "local" ]
    then
        _NAD=$_1APPLOCAL
    else
        _NAD=$_1APPGLOBAL
    fi
    for _NAA in $(_nh1app.avail)
    do
        _NAN=$(_nh1app.checkversion "$1" "$_NAA")

        if _nh1app.openapp $1
        then
            _NAP="$APP_PREFIX"
            _nh1app.closeapp
        fi

        for _NAF in $(ls $_NAD/$_NAP-* 2>/dev/null)
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
   done
}
