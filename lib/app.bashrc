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
  _1menuheader "$(_1text "Install App")"
  _1menuitem W 1app "$(_1text "List all available apps")"
  _1menuitem D 1appladd "$(_1text "Install or update an app locally")"
  _1menuitem D 1appgadd "$(_1text "Install or update an app globaly")"
  _1menuitem D 1appxadd "$(_1text "Install or update a package (using OS)")"
  _1menuitem D 1applupd "$(_1text "Update all local apps")"
  _1menuitem D 1appgupd "$(_1text "Update all global apps")"
  _1menuitem D 1appxupd "$(_1text "Upgrade all packages(using OS)")"
  _1menuitem D 1appldel "$(_1text "Remove a local app")"
  _1menuitem D 1appgdel "$(_1text "Remove a global app")"
  _1menuitem D 1applclear "$(_1text "Remove old versions for a local app (or all)")"
  _1menuitem D 1appgclear "$(_1text "Remove old versions for a global app (or all)")"
  _1menuitem D 1appxclear "$(_1text "Remove old versions for all system apps")"
  _1menuitem X 1appre "$(_1text "Helps to create regular expression to make a recipe")"
}

# @description Destroy all global variables created by this file
_nh1app.clean() {
  unset _1APPLOCAL _1APPLBIN _1APPGLOBAL _1APPGBIN _1APPLIB
  unset _1APPLAPPS _1APPGAPPS _1APPLICON _1APPGICON _1APPRETAINS
  unset -f _nh1app.menu _nh1app.clean _nh1app.setup 1app
  unset -f _nh1app.single _nh1app.add 1appladd 1appgadd 
  unset -f _nh1app.checkversion _nh1app.clist _nh1app.remove 
  unset -f _nh1app.checksetup _nh1app.description _nh1app.clear
  unset -f _nh1app.openapp _nh1app.closeapp _nh1app.avail
  unset -f 1applupd 1appgupd 1appldel 1appgdel 1applclear 1appgclear
  unset -f 1appxupd _nh1app.where _nh1app.complete _nh1app.mkdesktop
  unset -f _nh1app.clearold _nh1app.customvars _nh1app.info _nh1app.init
  unset -f _nh1app.update 1appxadd 1appxclear _nh1app.gitget 1appre
  unset -f _nh1app.list _nh1app.sysupdate _nh1app.sysadd _nh1app.sysdel
  unset -f _nh1app.sysclear _nh1app.nlist
}

# @description Autocompletion for 1app
_nh1app.complete() {
    _1verb "Enabling complete for 1app."
    complete -F _nh1app.nlist 1app
    complete -W "$(_nh1app.clist local 0)" 1appladd
    complete -W "$(_nh1app.clist global 0)" 1appgadd
    complete -W "$(_nh1app.clist local 1)" 1appldel
    complete -W "$(_nh1app.clist global 1)" 1appgdel
}

# @description List all available apps
# @stdout List of available apps
_nh1app.avail() {
    pushd $_1APPLIB > /dev/null
    ls *.app | 1remove '.app' | xargs
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

# @description Open app recipe file
# @arg $1 string App name
# @exitcode 0 It's ok
# @exitcode 1 File not found
# @see _nh1app.closeapp
_nh1app.openapp() {
    if [ -f "$_1APPLIB/$1.app" ]
    then
        source "$_1APPLIB/$1.app"
        if [ ! "$APP_PREFIX" ]
        then
            _1message warning "$(printf "$(_1text "No prefix defined for %s app!")" "$1")"
            APP_PREFIX="$1-"
        fi
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
# @arg $2 int Length to print
# @stdout Application description
_nh1app.description() {
    local _STR _SPACES _ILEN _FLEN
    _FLEN=$2
    if _nh1app.openapp $1
    then
        _STR="$APP_DESCRIPTION"
        _nh1app.closeapp
        _ILEN=${#_STR}
        _DIFF=$((_FLEN - _ILEN))
        printf "%s%${_DIFF}s" "$_STR" " "
    else
        echo -n "???"
    fi
}

# @description Returns latest version for github code
# @arg $1 string Github project owner
# @arg $2 string Github project name
_nh1app.ghversion() {
    curl -sL "https://github.com/$1/$2/releases/latest" | tr '\n' ' ' | sed 's/\(.*\)\/releases\/tag\/v\([0-9\.]*\)\"\(.*\)/\2/'
}

# @description Returns newest file version or actual
# @arg $1 string What to check: new, local or global
# @arg $2 string Application name
# @stdout Full file name
_nh1app.checkversion() {
    local _BINPATH _DIRPATH _DIRAUX
    if _nh1app.openapp $2
    then
        case "$1" in
            new)
                APP_VERSION                
                ;;
            local)
                if [ -L "$_1APPLBIN/$2" ]
                then
                    _BINPATH=$(readlink "$_1APPLBIN/$2")
                    _DIRPATH=$(dirname "$_BINPATH")
                    if [ "$_DIRPATH" = "$_1APPLBIN" ]
                    then
                        basename $_BINPATH
                    else
                        echo "$_BINPATH" | 1remove "$_1APPLOCAL/"
                    fi
                fi
                ;;
            global)
                if [ -L "$_1APPGBIN/$2" ]
                then
                    _BINPATH=$(readlink "$_1APPGBIN/$2")
                    _DIRPATH=$(dirname "$_BINPATH")
                    if [ "$DIRPATH" = "$_1APPGBIN" ]
                    then
                        basename "$_BINPATH"
                    else
                        echo "$_BINPATH" | 1remove "$_1APPGLOBAL/"
                    fi
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
    local _DIR _LAT _PRE _SCO _F _SU
    _DIR="$1"
    _LAT="$2"
    _PRE="$3"
    _SCO="$4"

    if [ "$_SCO" = "global" ]
    then
        _SU="_1sudo "
    else
        _SU=""
    fi

    if [ $_1APPRETAINS = 1 ]
    then
        for _F in $(find "$_DIR" -name "$_PRE*")
        do
            _F="$(basename "$_F")"
            if [ "$_LAT" != "$_F" ]
            then
                _1verb "$(printf "$(_1text "Removing old app version %s.")\n" $_F)"
                if [ -f "$_F" ]
                then
                    $_SU rm "$_DIR/$_F"
                elif [ -d "$_F" ]
                then
                    $_SU rm -r "$_DIR/$_F"
                fi
            fi
        done
    fi
}

# @description Downloader for git
# @arg $1 string App name
# @arg $2 string app-directory
# @arg $3 string symlink
# @arg $4 string local or global
_nh1app.gitget() {
    local _NAPP _NADIR _NASYM _NAS _NABIN
    if 1check git
    then
        _NAPP="$1"
        _NADIR="$2"
        _NASYM="$3/$1"
        _NAS=$4
        
        pushd $_NADIR > /dev/null

        _nh1app.openapp $_NAPP

        if [ -n "$APP_DEPENDS" ]
        then
            if ! 1check $APP_DEPENDS
            then
                _1message error "$(printf "$(_1text "App needs %s and it's not available.")" "$(1tint "$APP_DEPENDS")")"
                return 1
            fi
        fi

        if [ "$APP_TYPE" = "git" ]
        then
            printf "$(_1text "Git install/update for %s")\n"  "$(1tint $_1COLOR " $_NAPP")"

            if [ $_NAS = "global" ]
            then    
                APP_GET sudo
            else
                APP_GET
            fi

            if [ ! -L "$_NASYM" ]
            then
                _NABIN="$_NADIR/$_NAPP-git/$APP_BINARY"
                if [ $_NAS = "global" ]
                then
                    _1sudo ln -s "$_NABIN" "$_NASYM"
                else
                    ln -s "$_NABIN" "$_NASYM"
                fi
            fi

            # Creates a desktop file any way
            if [ -f "$_NASYM" ]
            then
                _nh1app.mkdesktop "$_NAPP" "$_NAS"
            fi

        else
            _1message error "$(_1text "Wrong app type.")"
            return 2
        fi
        _nh1app.closeapp
        popd > /dev/null
    fi
}

# @description Single downloader
# @arg $1 string App name
# @arg $2 string app-directory
# @arg $3 string symlink
# @arg $4 string local or global
_nh1app.single() {
    local _NAPP _NADIR _NASYM _NAS _NANEW _NATMP _PREV _NABIN
    if 1check curl
    then
        _NAPP="$1"
        _NADIR="$2"
        _NASYM="$3/$1"
        _NAS=$4
        _NANEW=$(_nh1app.checkversion new $_NAPP)
        
        pushd $_NADIR > /dev/null

        _nh1app.openapp $_NAPP

        if [ -n "$APP_DEPENDS" ]
        then
            if ! 1check $APP_DEPENDS
            then
                _1message error "$(printf "$(_1text "App needs %s and it's not available.")" "$(1tint "$APP_DEPENDS")")"
                return 1
            fi
        fi

        if [[ "$_NANEW" = *$APP_SUFFIX ]]
        then
            if [ "$APP_TYPE" = "single" -a -f "$_NADIR/$_NANEW" ]
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
            
                if [ -f "$_NADIR/$_NANEW" ]
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

            if [ "$APP_TYPE" = "single" -a ! -x "$_NANEW" ]
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
                _NABIN="$_NADIR/$_NANEW"
                if [ $_NAS = "global" ]
                then
                    _1sudo ln -s "$_NABIN" "$_NASYM"
                else
                    ln -s "$_NABIN" "$_NASYM"
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

# @description Tarball downloader
# @arg $1 string App name
# @arg $2 string app-directory
# @arg $3 string symlink
# @arg $4 string local or global
_nh1app.tarball() {
    local _NAPP _NADIR _NASYM _NAS _NANEW _NATMP _PREV _NABIN _SSYM
    if 1check curl
    then
        _NAPP="$1"
        _NADIR="$2"
        _NASYM="$3"
        _NAS=$4
        _NANEW=$(_nh1app.checkversion new $_NAPP)
        
        pushd $_NADIR > /dev/null

        _nh1app.openapp $_NAPP

        if [ -n "$APP_DEPENDS" ]
        then
            if ! 1check $APP_DEPENDS
            then
                _1message error "$(printf "$(_1text "App needs %s and it's not available.")" "$(1tint "$APP_DEPENDS")")"
                return 1
            fi
        fi

        if [[ "$_NANEW" = *$APP_SUFFIX ]]
        then
            if  [ "$APP_TYPE" = "tarball" -a -d "$_NADIR/$_NANEW" ]
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
            
                if [ -f "$_NADIR/$_NANEW" ]
                then
                    # If binary is a list, remove all symlinks
                    if [[ "$APP_BINARY" =~ ' ' ]]
                    then
                        for _SSYM in $APP_BINARY
                        do
                            if [ -L "$_NASYM/$_SSYM" ]
                            then        
                                if [ $_NAS = "global" ]
                                then        
                                    _1sudo rm "$_NASYM/$_SSYM"
                                else        
                                    rm "$_NASYM/$_SSYM"
                                fi  
                            fi
                        done
                    else
                        if [ -L "$_NASYM/$_NAPP" ]
                        then    
                            if [ $_NAS = "global" ]
                            then    
                                _1sudo rm "$_NASYM/$_NAPP"
                            else    
                                rm "$_NASYM/$_NAPP"
                            fi
                        fi
                    fi
                fi
            fi
        

            _nh1app.clearold "$_NADIR" "$_NANEW" "$APP_PREFIX" "$_NAS"

            if [ "$APP_TYPE" = "single" -a ! -x "$_NANEW" ]
            then
                if [ $_NAS = "global" ]
                then
                    _1sudo chmod a+x "$_NANEW"
                else
                    chmod a+x "$_NANEW"
                fi
            fi

            _NABIN="$_NADIR/$_NANEW"

            # If binary is a list, remove all symlinks
            if [[ "$APP_BINARY" =~ ' ' ]]
            then
                for _SSYM in $APP_BINARY
                do
                    if [ ! -L "$_NASYM/$_SSYM" ]
                    then        
                        if [ $_NAS = "global" ]
                        then        
                            _1sudo ln -s "$_NABIN/$_SSYM" "$_NASYM/$_SSYM"
                        else        
                        ln -s "$_NABIN/$_SSYM" "$_NASYM/$_SSYM"
                        fi  
                    fi
                done
            else
                if [ ! -L "$_NASYM" ]
                then
                    if [ $_NAS = "global" ]
                    then
                        _1sudo ln -s "$_NABIN/$APP_BINARY" "$_NASYM/$_NAPP"
                    else
                        ln -s "$_NABIN/$APP_BINARY" "$_NASYM/$_NAPP"
                    fi
                fi
            fi

            # Creates a desktop file any way
            if [ -f "$_NASYM/$_NAPP" ]
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
            tarball)
                _nh1app.tarball "$2" "$_NAD" "$_NAB" "$_NAS"
                 ;;
            git)
                _nh1app.gitget "$2" "$_NAD" "$_NAB" "$_NAS"
                ;;
            *)
                printf "$(_1text "Type unsuported: %s.")\n" $_NAT
            esac
    else
        echo "$(_1text "Unknown app: %s.")" $2
    fi
}

# @description Based on avail, list apps with filters
# @arg $1 string local or global
# @arg $2 int installed (1) or not-installed (0)
# @stdout A list of apps
_nh1app.clist() {
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

# @description New completion for 1app
# @arg $1 string local or global
# @arg $2 int installed (1) or not-installed (0)
# @stdout A list of apps
_nh1app.nlist() {
    local _SCO _COM
  	COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
		COMPREPLY=(list add del update clean help)
	elif [ "$COMP_CWORD" -eq 2 ]
	then
		COMPREPLY=(local global system)
    elif [ "$COMP_CWORD" -gt 2 ]
    then
		_COM=("${COMP_WORDS[1]}")
		_SCO=("${COMP_WORDS[2]}")
        case "$_COM" in
            add)
                if [ "$_SCO" != "system" ]
                then
                    COMPREPLY=($(_nh1app.clist "$_SCO" 0))
                fi
                ;;
            del)
                if [ "$_SCO" != "system" ]
                then
                    COMPREPLY=($(_nh1app.clist "$_SCO" 1))
                fi
                ;;
        esac
    fi
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

# @description Removes an installed app
# @arg $1 string local or global 
# @arg $2 string App name
_nh1app.remove() {
    local _NAA _NAF _SSYM
    _NAA=$2
    _NAF=$(_nh1app.checkversion $1 $_NAA)
    _1verb "$(printf "$(_1text "App %s removed with file %s")" $_NAA $_NAF)"
    _nh1app.openapp $_NAA
    if [ -n "$_NAF" ]
    then
        if [ "$1" = "local" ]
        then
            rm -r "$_1APPLOCAL/$_NAF"
            rm -f "$_1APPLAPPS/$_NAA.desktop"
            rm -f "$_1APPLICON/$_NAA.png"
            if [[ "$APP_BINARY" =~ ' ' ]]
            then
                for _SSYM in $APP_BINARY
                do
                    rm "$_1APPLBIN/$_SSYM"
                done
            else
                rm "$_1APPLBIN/$_NAA"
            fi
        else
            _1sudo rm -r "$_1APPGLOBAL/$_NAF"
            _1sudo rm -f "$_1APPGAPPS/$_NAA.desktop"
            _1sudo rm -f "$_1APPLICON/$_NAA.png"
            if [[ "$APP_BINARY" =~ ' ' ]]
            then
                for _SSYM in $APP_BINARY
                do
                    _1sudo rm "$_1APPLBIN/$_SSYM"
                done
            else
                _1sudo rm "$_1APPGBIN/$_NAA"
            fi
        fi
    fi
    _nh1app.closeapp
}

# @description Clear unused old versions for every app
# @arg $1 string local or global
_nh1app.clear() {
    local _NAA _NAN _NAF _NAD _NAP _NAT
    _NAP="none"
    if [ $1 = "local" ]
    then
        _NAD=$_1APPLOCAL
    else
        _NAD=$_1APPGLOBAL
    fi
    for _NAA in $(_nh1app.avail)
    do
        _NAN=$(_nh1app.checkversion "$1" "$_NAA")

        if _nh1app.openapp $_NAA
        then
            _NAP="$APP_PREFIX"
            _NAT="$APP_TYPE"
            _nh1app.closeapp
        fi

        if [ "$_NAT" = "single" -o "$_NAT" = "tarball" ]
        then

            for _NAF in $(ls $_NAD/$_NAP* 2>/dev/null)
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
        fi
   done
}

# @description List all available app image for installation
_nh1app.list() {
    local _NAA _NAS _NAU _NAC
    echo "___ $(_1text "1app status") ___"
    printf "%-15s %-45s%s\n" "$(_1text App)" "$(_1text Description)" "$(_1text Installation)"
    for _NAA in $(_nh1app.avail)
    do
        printf "%-15s %s" "$_NAA" "$(_nh1app.description $_NAA 45)"
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
    _1message "$(printf "$(_1text "Use %s to usage instructions.")" "$(1tint "1app help")")"
}

# @description Install program using system package manager
# @arg $1 string Package name
# @exitcode 0
_nh1app.sysadd() {
    local _PKG _OUT _AID _REM

    _PKG="$1"
        
    if _nh1app.where dnf > /dev/null
    then
        _1message "$(printf "$(_1text "Searching %s in %s...")\n" "$_PKG" "dnf")"
        if $(dnf search -q "$_PKG" | grep -q "^$_PKG\.")
        then
            _1verb "$(printf "$(_1text "Package %s found in %s.")\n" "$_PKG" "dnf")"
            _1sudo dnf install "$_PKG"
            return 0
        elif $(dnf search -q "${_PKG^}" | grep -q "^${_PKG^}\.")
        then
            _1verb "$(printf "$(_1text "Package %s found in %s.")\n" "${_PKG^}" "dnf")"
            _1sudo dnf install "${_PKG^}"
            return 0
        else
            printf "$(_1text "Package %s not found in %s.")\n" "$_PKG" "dnf"
        fi
    fi

    if _nh1app.where apt > /dev/null
    then
        _1message "$(printf "$(_1text "Searching %s in %s...")\n" "$_PKG" "apt")"
        if $(apt show "$_PKG" &>/dev/null)
        then
            _1verb "$(printf "$(_1text "Package %s found in %s.")\n" "$_PKG" "apt")"
            _1sudo apt update
            _1sudo apt install "$_PKG"
            _1sudo apt clean
            return 0
        else
            printf "$(_1text "Package %s not found in %s.")\n" "$_PKG" "apt"
        fi
    fi

    if _nh1app.where flatpak > /dev/null
    then
        _OUT=$(LANG=EN flatpak search "$_PKG" | egrep -i "^$_PKG")
        if [ $? -eq 0 ]
        then
            _1message "$(printf "$(_1text "Searching %s in %s...")\n" "$_PKG" "flatpak")"
            if [ $(LANG=EN flatpak search "$_PKG" | egrep -i "^$_PKG" | wc -l) -eq 1 ]
            then
                _AID="$(LANG=EN flatpak search "$_PKG" | egrep -i "^$_PKG" | sed 's/\(.*\)\t\([a-ZA-Z]*\.[a-zA-Z0-9\.]*\)\t\(.*\)/\2/')"
                _REM="$(LANG=EN flatpak search "$_PKG" | egrep -i "^$_PKG" | sed 's/\(.*\)\t\([a-zA-Z0-9\.]*\)$/\2/')"
                _1sudo flatpak install "$_REM" "$_AID"
                return 0
            else
                echo $_OUT
                _1message warning "$(_1text "The search returned more than one result!")"
            fi
            _1verb "$(printf "$(_1text "Package %s found in %s.")\n" "$_PKG" "flatpak")"
        else
            printf "$(_1text "Package %s not found in %s.")\n" "$_PKG" "flatpak"
        fi

    fi


    # Pending: zypper pacman snap
    printf "$(_1text "Sorry. Package %s not found in known/installed package managers.")\n" "$_PKG"
}

# @description Upgrade all system packages
_nh1app.sysupdate() {
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

# @description Uninstall a system application
# @arg $1 string Application to uninstall
_nh1app.sysdel() {
    local _PM _AUX
    
    if _nh1app.where dnf > /dev/null
    then
        rpm -q $1
        if [ $? -eq 0 ]
        then
            _1sudo dnf remove $1
            return 0
        fi
    fi    

    if _nh1app.where apt > /dev/null
    then
        dpkg -s $1
        if [ $? -eq 0 ]
        then
            _1sudo apt remove $1
            return 0
        fi
    fi

    if _nh1app.where snap > /dev/null
    then
        _AUX= $(snap info $1 2>/dev/null | grep installed | wc -l)
        if [ $_AUX -eq 1 ]
        then
            _1sudo snap remove $1
            if [ $? -eq 0 ]
            then
                return 0
            fi
        fi
    fi

    if _nh1app.where flatpak > /dev/null
    then
        _AUX=$(flatpak search $1 | tail -n 1 | tr '\t' '_' | cut -d_ -f 3)
        if [ "$_AUX" != "" ]
        then
            flatpak info $_AUX &>/dev/null
            if [ $? -eq  0 ]
            then
                _1sudo flatpak remove $1
                if [ $? -eq 0 ]
                then
                    return 0
                fi
            fi

        fi
    fi

    _1message "$(_1text "App not found.")"
}

# @description Remove old versions of system apps, in debian, snap, flatpak...
_nh1app.sysclear() {
	_1before
    local _APP _AUX
    if _nh1app.where snap > /dev/null
    then
        _1message info "$(_1text "Cleaning %s...")\n" snap
        LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' | \
            while read _APP _AUX
            do
                _1sudo snap remove "$_APP" --revision="$_AUX"
            done
    fi

    if _nh1app.where flatpak > /dev/null
    then
        printf "$(_1text "Cleaning %s...")\n" flatpak
        _1sudo flatpak uninstall --unused
    fi
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1app.usage() {
  case $1 in
    app)
        printf "$(_1text "Usage: %s [%s] [%s] [%s]")\n" "1$1" "$(_1text "command")" "$(_1text "scope")" "$(_1text "option")"
        printf "  $(_1text "Commands"):\n"
        printf "  - $(1tint list): $(_1text "list all available commands")\n"
        printf "  - $(1tint add): $(_1text "install/update an application")\n"
        printf "  - $(1tint del): $(_1text "uninstall an application")\n"
        printf "  - $(1tint update): $(_1text "Update all installed packages")\n"
        printf "  - $(1tint clean): $(_1text "Remove old files and caches")\n"
        printf "  - $(1tint help): $(_1text "show this usage instructions")\n"
        printf "  $(_1text "Scopes"):\n"
        printf "  - $(1tint local): $(_1text "installed in user space")\n"
        printf "  - $(1tint global): $(_1text "installed for all users, with binaries in %s")\n" "/usr/local/bin"
        printf "  - $(1tint system): $(_1text "installed with system package managers (apt, dnf, snap, etc)")\n"
        printf "  - $(1tint all): $(_1text "all installations: local, global and system")\n"
        ;;
  esac
}

# Alias-like

# @description App manager
# @arg $1 string Command
# @arg $2 string scope
# @arg $3 string complementar argument
1app() {
	_1before
    local _COM _SCO
    _COM="list"
    if [ $# -gt 0 ]
    then
        _COM="$1"
        shift
    fi
    if [ $# -gt 0 ]
    then
        _SCO="$1"
        shift
    fi
    case $_COM in
        list)
            _nh1app.list
            ;;
        add)
            case $_SCO in 
                global|local)
                    _nh1app.add "$_SCO" $*
                    ;;
                system)
                    _nh1app.sysadd $*
                    ;;
                *)
                    _nh1app.usage app
                    ;;
            esac          
            ;;     
        del)
            case $_SCO in 
                global|local)
                    _nh1app.remove "$_SCO" $*
                    ;;
                system)
                    _nh1app.sysdel $*
                    ;;
                *)
                    _nh1app.usage app
                    ;;
            esac          
            ;;     
        update)
            case $_SCO in 
                global|local)
                    _nh1app.update "$_SCO"
                    ;;
                system)
                    _nh1app.sysupdate
                    ;;
                all)
                    _1message "$(printf "$(_1text "Updating %s applications.")" "local")"
                    _nh1app.update "local"
                    _1message "$(printf "$(_1text "Updating %s applications.")" "global")"
                    _nh1app.update "global"
                    _1message "$(printf "$(_1text "Updating %s applications.")" "system")"
                    _nh1app.sysupdate     
                    ;;
                *)
                    _nh1app.usage app
                    ;;
            esac          
            ;;     
        clean)
            case $_SCO in 
                global|local)
                    _nh1app.clear "$_SCO"
                    ;;
                system)
                    _nh1app.sysclear
                    ;;
                all)
                    _nh1app.clear "local"
                    _nh1app.clear "global"
                    _nh1app.sysclear
                    ;;
                *)
                    _nh1app.usage app
                    ;;
            esac
            ;;
        *)
            _nh1app.usage app
            ;;
    esac
}

# @description Run a regular expression and return info to help you to create a 1app recipe
# @arg $1 string Target URL
# @arg $2 string String to search
1appre() {
    local _URL _EXP _RES _RE
    _URL="$1"
    _EXP="$2"
    _RE='\(.*\)\(.\{100\}%s.\{100\}\)\(.*\)'
    _RES=$(curl -s "$_URL" | tr '\n' ' ' | sed "s/$(printf "$_RE" "$_EXP")/\2/" | grep -v "DOCTYPE")
    if [ -n "$_RES" ]
    then
        echo "$_RES"
        _1text "It works."
        echo
        printf "RE: $_RE\n" "$_EXP"
    else
        _1text "String not found in URL page."
        echo
    fi
}

1appxupd() {
    1app update system
}

1applupd()   {
    1app update local
}

1appgupd()   {
    1app update global
}

1appladd() {
    1app add local $*
}

1appgadd() {
    1app add global $*
}

1appxadd() {
    1app add system $*    
}

1appldel()   {
    1app del "local" "$1"
}

1appgdel()   {
    1app del "global" "$1"
}

1applclear() {
    1app clean "local"
}

1appgclear() {
    1app clean "global"
}

1appxclear() {
    1app clean "system"
}
