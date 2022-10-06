#!/bin/bash

# GLOBALS

_1BACKDIR="$HOME/Backup"
_1BACKMAX=0

# Generate partial menu
function _nh1backup.menu {
  echo "___ Backup tools ___"
  _1menuitem X 1backup "Make backup of a dir"
  _1menuitem P 1unback "Restore a backup"
  _1menuitem X 1backlist "List saved backups"
  }

# Destroy all global variables created by this file
function _nh1backup.clean {
  unset _1BACKDIR _1BACKMAX
  unset -f 1backup 1unback 1backlist  _nh1backup.nextfile _nh1backup.maxcontrol
  unset -f _nh1backup.log _nh1backup.custom 1backlist _nh1backup.names
}

function _nh1backup.names {
    if [ "$(find "$_1BACKDIR" -name '*-????-??-??*')" != "" ]
    then
        find "$_1BACKDIR" -name '*-????-??-??*' | xargs -n 1 basename | \
            sed 's/\(.*\)\(-....-..-..\)\(.*\)/\1/g' | sort | uniq | xargs
    fi
}

function _nh1backup.complete {
    _1verb "Enabling complete for 1backup."
    complete -W "$(_nh1backup.names)" 1backlist
}

# Load variables defined by user
function _nh1backup.custom {
    if [[ $NORG_BACKUP_DIR ]]
    then
        _1BACKDIR="$NORG_BACKUP_DIR"
    fi
    if [[ $NORG_BACKUP_MAX ]]
    then
        _1BACKMAX="$NORG_BACKUP_MAX"
    fi
}

function _nh1backup.log {
    local _NOW _L1 _L2 _L3
    _NOW=$(date "+%Y-%m-%d %X")
    mkdir -p "$_1UDATA/log"
    _L1="$_1UDATA/log/backup.txt"
    _L2="$_1BACKDIR/log.txt"
    _L3=$(date "+$_1BACKDIR/%Y/%m/log.txt")
    echo "$_NOW: $*" >> $_L1
    echo "$_NOW: $*" >> $_L2
    echo "$_NOW: $*" >> $_L3
}

# Controls max number of files
# @param Name (id)
# @param Directory for saved backups
function _nh1backup.maxcontrol {
    local _NAME _DEST
    _NAME="$1"
    _DEST=$(date "+$_1BACKDIR/%Y/%m")
    if [ $_1BACKMAX -gt 0 ]
    then
        _1verb "Scanning $_DEST/$_NAME-*"
        _OLD=($(ls --sort=time $_DEST/$_NAME-*))
        while [[ ${#_OLD[@]} -gt $_1BACKMAX ]]
        do
            _1verb "There are " ${#_OLD[@]} " backups. Max is $_1BACKMAX. Removing " ${_OLD[0]}
            if rm ${_OLD[0]}
            then
                _nh1backup.log "Removed file ${_OLD[0]} from $_DEST"
            else    
                _nh1backup.log "ERROR removing ${_OLD[0]} from $_DEST... $?"
            fi
            _OLD=("${_OLD[@]:1}")
        done
    fi
}

# Returns next filename for base and extension
# @param Name (id)
# @param Extension
function _nh1backup.nextfile {
    local _NAME _EXT _FILE _DEST _COUNT
    _NAME="$1"
    _EXT="$2"
    _DEST=$(date "+$_1BACKDIR/%Y/%m")
    _FILE=$(date "+$_NAME-%Y-%m-%d")
    _COUNT=0

    mkdir -p "$_DEST"

    if [ -f "$_DEST/$_FILE.$_EXT" ]
    then
        while [ -f "$_DEST/$_FILE.$_COUNT.$_EXT" ]
        do
            _COUNT=$((_COUNT + 1))
        done
        _FILE="$_DEST/$_FILE.$_COUNT.$_EXT"
    else
        _FILE="$_DEST/$_FILE.$_EXT"
    fi

    echo $_FILE
}

# Make backup of a directory
# @param Name (id) for backup
# @param Directory to backup
function 1backup {
    local _NAME _TARGET _DEST _FILE _COMPL _COUNT _OLD
    _NAME="$1"
    _TARGET="$2"

    _nh1backup.custom

    if [ $# -eq 2 ]
    then
        if 1check 7z
        then        
            _FILE=$(_nh1backup.nextfile "$_NAME" "7z")
            _1verb "Running 7zip for $_TARGET, saving in $_FILE..."
            if 7z a "$_FILE" "$_TARGET"
            then
                _nh1backup.log "7zip for $_TARGET, save in $_FILE..."
            else
                _nh1backup.log "ERROR 7zip for $_TARGET, save in $_FILE... $?"
            fi
        elif 1check zip
        then
            _FILE=$(_nh1backup.nextfile "$_NAME" "zip")
            _1verb "Running zip for $_TARGET, saving in $_FILE..."
            if zip -r "$_FILE" "$_TARGET"
            then
                _nh1backup.log "zip for $_TARGET, save in $_FILE..."
            else
                _nh1backup.log "ERROR zip for $_TARGET, save in $_FILE... $?"
            fi
        elif 1check tar
        then
            if 1check xz
            then
                _FILE=$(_nh1backup.nextfile "$_NAME" "tar.xz")
                _1verb "Running tar with xz for $_TARGET, saving in $_FILE..."
                if tar -cJf "$_FILE" "$_TARGET"
                then
                    _nh1backup.log "tar for $_TARGET, save in $_FILE..."
                else    
                    _nh1backup.log "ERROR tar for $_TARGET, save in $_FILE... $?"
                fi
            elif 1check bzip2
            then
                _FILE=$(_nh1backup.nextfile "$_NAME" "tar.bz2")
                _1verb "Running tar with bzip2 for $_TARGET, saving in $_FILE..."
                if tar -cjf "$_FILE" "$_TARGET"
                then
                    _nh1backup.log "tar for $_TARGET, save in $_FILE..."
                else    
                    _nh1backup.log "ERROR tar for $_TARGET, save in $_FILE... $?"
                fi
            elif 1check gzip
            then
                _FILE=$(_nh1backup.nextfile "$_NAME" "tar.gz")
                _1verb "Running tar with gzip for $_TARGET, saving in $_FILE..."
                if tar -czf "$_FILE" "$_TARGET"
                then
                    _nh1backup.log "tar for $_TARGET, save in $_FILE..."
                else    
                    _nh1backup.log "ERROR tar for $_TARGET, save in $_FILE... $?"
                fi
            else            
                echo "Running tar without compression! Install gzip, bzip2 or xz!"
                _FILE=$(_nh1backup.nextfile "$_NAME" "tar")
                _1verb "Running tar without compression for $_TARGET, saving in $_FILE..."
                if tar -cf "$_FILE" "$_TARGET"
                then
                    _nh1backup.log "tar for $_TARGET, save in $_FILE..."
                else    
                    _nh1backup.log "ERROR tar for $_TARGET, save in $_FILE... $?"
                fi
            fi
        else
            echo "No compressor found. Try to install 7zip, zip or tar (with gzip, bzip2 or xz)."
        fi

        _nh1backup.maxcontrol "$_NAME"

    else
        echo "Usage: 1backup <name> <directory>"
        echo "  - Name: backup id"
        echo "  - Directory: target to backup"
        echo "    Backups are saved in $_1BACKDIR"
    fi
}

# List all backups for one name (id)
# @param Name (id)
function 1backlist {
    _nh1backup.custom
    if [ $# -eq 1 ]
    then
        find "$_1BACKDIR" -name "$1*"
    else
        echo "Use 1backlist <name> to find all backups for <name>."
        echo -n "Names: "
        _nh1backup.names
    fi
}