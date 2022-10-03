#!/bin/bash

# GLOBALS

_1BACKDIR="$HOME/Backup"
_1BACKMAX=0

# Generate partial menu
function _nh1app.menu {
  echo "___ Install App ___"
  _1menuitem X 1backup "Make backup of a dir"
  _1menuitem P 1unback "Restore a backup"
  _1menuitem P 1backlist "List saved backups"
  }

# Destroy all global variables created by this file
function _nh1back.clean {
  unset _1BACKDIR _1BACKMAX
  unset -f 1backup 1unback 1backlist  
}

# Alias-like

function _nh1back.complete {
    _1verb "Enabling complete for 1backup."
    #complete -W "$(_nh1app.list local 0)" 1appladd
    #complete -W "$(_nh1app.list global 0)" 1appgadd
    #complete -W "$(_nh1app.list local 1)" 1appldel
    #complete -W "$(_nh1app.list global 1)" 1appgdel
}

# Controls max number of files
# @param Name (id)
# @param Directory for saved backups
function _nh1back.maxcontrol {
    local _NAME _DEST
    _NAME="$1"
    _DEST="$2"
    if [ $_1BACKMAX -gt 0 ]
    then
        _1verb "Scanning $_DEST/$_NAME-*"
        _OLD=($(ls --sort=time $_DEST/$_NAME-*))
        while [[ ${#_OLD[@]} -gt $_1BACKMAX ]]
        do
            _1verb "There are " ${#_OLD[@]} " backups. Max is $_1BACKMAX. Removing " ${_OLD[0]}
            rm ${_OLD[0]}
            _OLD=("${_OLD[@]:1}")
        done
    fi
}

# Make backup of a directory
# @param Name (id) for backup
# @param Directory to backup
function 1backup {
    local _NAME _TARGET _DEST _FILE _COMPL _COUNT _OLD
    _NAME="$1"
    _TARGET="$2"
    _DEST=$(date "+$_1BACKDIR/%Y/%m")
    _FILE=$(date "+$_NAME-%Y-%m-%d")
    _COMPL=""
    _COUNT=0
    _1verb "Name $_NAME, Target $_TARGET, save to $_DEST."
    mkdir -p "$_DEST"

    if 1check 7z
    then        
        _COMPL=".7z"
        if [ -f "$_DEST/$_FILE$_COMPL" ]
        then
            while [ -f "$_DEST/$_FILE.$_COUNT$_COMPL" ]
            do
                _COUNT=$((_COUNT + 1))
            done
            _FILE="$_DEST/$_FILE.$_COUNT$_COMPL"
        else
            _FILE="$_DEST/$_FILE$_COMPL"
        fi
        _1verb "Running 7zip for $_TARGET, saving in $_FILE..."
        7z a "$_FILE" "$_TARGET"
        _1verb "7zip finished."
    else
        echo "7zip not installed."
    fi

    _nh1back.maxcontrol "$_NAME" "$_DEST"

}
