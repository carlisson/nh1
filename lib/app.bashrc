#!/bin/bash
# @file app.bashrc
# @brief Package manager for AppImage applications

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
_1APPRETAINS=0

# @description Generates partial menu
_nh1app.menu() {
  echo "___ $(_1text "Install App") ___"
  _1menuitem W 1app "$(_1text "List all available apps")"
  _1menuitem W 1appladd "$(_1text "Install or update an app locally")"
  _1menuitem W 1appgadd "$(_1text "Install or update an app globaly")"
  _1menuitem W 1applupd "$(_1text "Update all local apps")"
  _1menuitem W 1appgupd "$(_1text "Update all global apps")"
  _1menuitem W 1appxupd "$(_1text "Upgrade all packages(using OS)")"
  _1menuitem W 1appldel "$(_1text "Remove a local app")"
  _1menuitem W 1appgdel "$(_1text "Remove a global app")"
  _1menuitem W 1applclear "$(_1text "Remove old versions for a local app (or all)")"
  _1menuitem W 1appgclear "$(_1text "Remove old versions for a global app (or all)")"
}

# @description Destroy all global variables created by this file
_nh1app.clean() {
  unset _1APPLOCAL _1APPLBIN _1APPGLOBAL _1APPGBIN _1APPLIB
  unset _1APPLAPPS _1APPGAPPS _1APPLICON _1APPGICON _1APPRETAINS
  unset -f _nh1app.menu _nh1app.clean _nh1app.setup 1app
  unset -f _nh1app.single _nh1app.add 1appladd 1appgadd 
  unset -f _nh1app.checkversion _nh1app.list _nh1app.remove 
  unset -f _nh1app.checksetup _nh1app.description _nh1app.clear
  unset -f _nh1app.openapp _nh1app.closeapp _nh1app.avail
  unset -f 1applupd 1appgupd 1appldel 1appgdel 1applclear 1appgclear
  unset -f 1appxupd _nh1app.where _nh1app.complete _nh1app.mkdesktop
  unset -f _nh1app.clearold _nh1app.customvars _nh1app.info _nh1app.init
  unset -f _nh1app.update
}

# Alias-like

# @description Update all local apps
1applupd()   { _nh1app.update local ; }

# @description Update all global apps
1appgupd()   { _nh1app.update global ; }

# @description Uninstall local app
# @arg $1 string Application name
1appldel()   { _nh1app.remove local "$1"; }

# @description Uninstall global app
# @arg $1 string Application name
1appgdel()   { _nh1app.remove global "$1"; }

# @description Remove old versions of local apps
1applclear() { _nh1app.clear local ; }

# @description Remove old versions of global apps
1appgclear() { _nh1app.clear global ; }

# @description Autocompletion for 1app
_nh1app.complete() {
    _1verb "Enabling complete for 1app."
    complete -W "$(_nh1app.list local 0)" 1appladd
    complete -W "$(_nh1app.list global 0)" 1appgadd
    complete -W "$(_nh1app.list local 1)" 1appldel
    complete -W "$(_nh1app.list global 1)" 1appgdel
}

# @description List all available apps
# @stdout List of available apps
_nh1app.avail() {
    pushd $_1APPLIB > /dev/null
    ls *.app | sed 's/.app//g' | tr '\n' ' '
    popd -n > /dev/null
}

# @description Configure your local or global path/dir
# @arg $1 string local or global
_nh1app.setup() {
    if [ "$1" = "local" ]
    then
        mkdir -p "$_1APPLOCAL"
        mkdir -p "$_1APPLBIN"
        mkdir -p "$_1APPLAPPS"
        mkdir -p "$_1APPLICON"
        grep "$_1APPLBIN" "$HOME/.bashrc" 2>&1 > /dev/null
        if [ $? -ne 0 ]
        then
            echo "PATH=\"\$PATH:$_1APPLBIN\"" >> "$HOME/.bashrc"
        fi
    else
        _1sudo mkdir -p "$_1APPGLOBAL"
    fi
}

# @description Startup function
# @see _nh1app.setup
_nh1app.init() {
    _nh1app.setup local
}

# @description Apply custom vars
_nh1app.customvars() {
    _1customvar NORG_APP_RETAINS _1APPRETAINS number
}

# @description Information about custom vars
# @see _nh1app.customvars
_nh1app.info() {
    _1menuitem W NORG_APP_RETAINS "$(_1text "Retains old app files? (1 or 0). Default: 0")"
}

# @description Check if setup is ok
# @arg $1 string local or global
# @exitcode 0 Setup is ok
# @exitcode 1 Setup is not ok
_nh1app.checksetup() {
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

# @description List all available app image for installation
1app() {
    local _NAA _NAS _NAU _NAC
    echo "___ $(_1text "1app status") ___"
    printf "%-15s %-45s%s\n" "$(_1text App)" "$(_1text Description)" "$(_1text Installation)"
    for _NAA in $(_nh1app.avail)
    do
        printf "%-15s %-45s" "$_NAA" "$(_nh1app.description $_NAA)"
        _NAC=0
        _NAU=$(_nh1app.checkversion local "$_NAA")
        if [ -n "$_NAU" ]
        then
            1tint 6 "$(_1text local) "
            _NAC=$((_NAC+1))
        fi
        _NAU=$(_nh1app.checkversion global "$_NAA")
        if [ -n "$_NAU" ]
        then
            1tint 6 "$(_1text global) "
            _NAC=$((_NAC+1))
        fi
        if [ "$_NAC" -eq 0 ]
        then
            if 1check -s "$_NAA"
            then
                1tint 6 "$(_1text system)"
            else
                echo -n "$(_1text None)"
            fi
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

# @description Open app recipe file
# @arg $1 string App name
# @exitcode 0 It's ok
# @exitcode 1 File not found
# @see _nh1app.closeapp
_nh1app.openapp() {
    if [ -f "$_1APPLIB/$1.app" ]
    then
        source "$_1APPLIB/$1.app"
        if [ ! "$APP_SUFFIX" ]
        then
            # _1verb "$(printf "$(_1text "Suffix not found in app recipe. Using %s.")\n" ".AppImage")"
            APP_SUFFIX=".AppImage"
        fi
        return 0
    else
        return 1
    fi
}

# @description Close app recipe (clear all loaded vars for recipe)
# @see _nh1app.openapp
_nh1app.closeapp() {
  unset APP_DESCRIPTION APP_TYPE APP_BINARY APP_DEPENDS APP_PREFIX
  unset APP_NAME APP_CATEGORIES APP_MIME APP_SUFFIX
  unset -f APP_POSTINST APP_VERSION APP_GET
}

# @description Returns description for an available app
# @arg $1 string Application name
# @stdout Application description
_nh1app.description() {
    if _nh1app.openapp $1
    then
        echo -n $APP_DESCRIPTION
        _nh1app.closeapp
    else
        echo -n "???"
    fi
}

# @description Returns newest file version or actual
# @arg $1 string What to check: new, local or global
# @arg $2 string Application name
# @stdout Full file name
_nh1app.checkversion() {
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

# @description Creates a Desktop file
# @arg $1 string App internal name
# @arg $2 string local or global
_nh1app.mkdesktop() {
    local _APP _NATMP
    _APP="$1"
    
    _1verb "$(printf "$(_1text "Creating desktop file for %s.")\n" $_APP)"

    if [ -f "$_1APPLIB/$_APP.png" ]
    then
        _NATMP=$(mktemp)                    
        cp "$_1LIB/templates/blank.desktop" "$_NATMP"
        echo "Name=$APP_NAME" >> "$_NATMP"
        echo "Comment=$APP_DESCRIPTION (NH1)" >> "$_NATMP"
        if [[ $APP_CATEGORIES ]]
        then
            echo "Categories=$APP_CATEGORIES" >> "$_NATMP"
        fi
        if [[ $APP_MIME ]]
        then
            echo "Mime=$APP_MIME" >> "$_NATMP"
        fi
        echo "Exec=$_NASYM" >> "$_NATMP"
        
        if [ $2 = "global" ]
        then
            _1sudo cp "$_1APPLIB/$_APP.png" "$_1APPGICON/"
            echo "Icon=$_1APPGICON/$_APP.png" >> "$_NATMP"
            _1sudo cp "$_NATMP" "$_1APPGAPPS/$_APP.desktop"
            _1sudo chmod a+r "$_1APPGAPPS/$_APP.desktop"
        else
            cp "$_1APPLIB/$_APP.png" "$_1APPLICON/"
            echo "Icon=$_1APPLICON/$_APP.png" >> "$_NATMP"
            cp "$_NATMP" "$_1APPLAPPS/$_APP.desktop"
            chmod a+r "$_1APPLAPPS/$_APP.desktop"
        fi
        rm "$_NATMP"
    else
        _1verb "$(_1text "No PNG for app. No desktop file created.")"
    fi
}

# @description Removes old files for app
# @arg $1 string Path of files
# @arg $2 string Latest file name
# @arg $3 string App prefix
# @arg $4 string local or global
_nh1app.clearold() {
    local _DIR _LAT _PRE _SCO _F
    _DIR="$1"
    _LAT="$2"
    _PRE="$3"
    _SCO="$4"

    if [ $_1APPRETAINS = 1 ]
    then
        for _F in $(find "$_DIR" -name "$_PRE*")
        do
            _F="$(basename "$_F")"
            if [ "$_LAT" != "$_F" ]
            then
                _1verb "$(printf "$(_1text "Removing old file %s.")\n" $_F)"
                if [ "$_SCO" = "local" ]
                then
                    rm "$_DIR/$_F"
                else
                    sudo rm "$_DIR/$_F"
                fi
            fi
        done
    fi
}

# @description Single downloader
# @arg $1 string App name
# @arg $2 string app-directory
# @arg $3 string symlink
# @arg $4 string local or global
_nh1app.single() {
    local _NAPP _NADIR _NASYM _NAS _NANEW _NATMP _PREV
    if 1check curl
    then
        _NAPP="$1"
        _NADIR="$2"
        _NASYM="$3/$1"
        _NAS=$4
        _NANEW=$(_nh1app.checkversion new $_NAPP)
        
        pushd $_NADIR > /dev/null
        _nh1app.openapp $_NAPP
        if [[ "$_NANEW" = *$APP_SUFFIX ]]
        then
            if [ -f "$_NADIR/$_NANEW" ]
            then
                printf "$(_1text "%s is already up to date.")\n" $_NAPP
            else
                _1text "To install/upgrade:"
                1tint $_1COLOR " $_NAA"
                echo

                if [ $_NAS = "global" ]
                then    
                    APP_GET sudo
                else
                APP_GET
                fi
            
                if [ -f "$__NADIR/$_NANEW" ]
                then
                    if [ -L "$_NASYM" ]
                    then    
                        if [ $_NAS = "global" ]
                        then    
                            _1sudo rm "$_NASYM"
                        else    
                            rm "$_NASYM"
                        fi
                    fi
                fi
            fi
        

            _nh1app.clearold "$_NADIR" "$_NANEW" "$APP_PREFIX" "$_NAS"

            if [ ! -x "$_NANEW" ]
            then
                if [ $_NAS = "global" ]
                then
                    _1sudo chmod a+x "$_NANEW"
                else
                    chmod a+x "$_NANEW"
                fi
            fi

            if [ ! -L "$_NASYM" ]
            then
                if [ $_NAS = "global" ]
                then
                    _1sudo ln -s "$_NADIR/$_NANEW" "$_NASYM"
                else
                    ln -s "$_NADIR/$_NANEW" "$_NASYM"
                fi
            fi

            # Creates a desktop file any way
            if [ -f "$_NASYM" ]
            then
                _nh1app.mkdesktop "$_NAPP" "$_NAS"
            fi
        
        else
        
            printf "$(_1text "Error geting %s file name. Check the recipe or try again later.")\n" $APP_NAME

        fi

        _nh1app.closeapp
        popd > /dev/null
    else
        printf "$(_1text "%s not found.")\n" "curl"
    fi    
}

# @description Internal 1app generic installer
# @arg $1 string local or global
# @arg $2 string App to install
_nh1app.add() {
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

# @description Install locally an app
# @arg $1 string App to install
# @see _nh1app.add
1appladd() {
    local _NAA
    for _NAA in "$@"
    do
        _nh1app.add local "$_NAA"
    done
}

# @description Install globally an app
# @arg $1 string App to install
# @see _nh1app.add
1appgadd() {
    local _NAA
    for _NAA in "$@"
    do
        _nh1app.add global "$_NAA"
    done
}

# @description Based on avail, list apps with filters
# @arg $1 string local or global
# @arg $2 int installed (1) or not-installed (0)
# @stdout A list of apps
_nh1app.list() {
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

# @description Update all installed apps
# @arg $1 string local or global
_nh1app.update() {
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

# @description Returns full path for a command, if exists
# @arg $1 string App to test
# @stdout Path for command
# @exitcode 0 Command exists
# @exitcode 1 Command not found
_nh1app.where() {
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

# @description Upgrade all system packages
1appxupd() {
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

# @description Removes an installed app
# @arg $1 string local or global 
# @arg $2 string App name
_nh1app.remove() {
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

# @description Clear unused old versions for every app
# @arg $1 string local or global
_nh1app.clear() {
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
