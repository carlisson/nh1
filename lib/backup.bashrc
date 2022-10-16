#!/bin/bash

# GLOBALS

_1BACKDIR="$HOME/Backup"
_1BACKMAX=0
_1BACKGRP='m' # options: d,w,m,y,n
# NORG/backup.dirs : aliases Name > original path

# Generate partial menu
function _nh1backup.menu {
  echo "___ $(_1text "Backup tools") ___"
  _1menuitem W 1backup "$(_1text "Make backup of a dir")"
  _1menuitem P 1unback "$(_1text "Restore a backup")"
  _1menuitem W 1backlist "$(_1text "List saved backups")"
  }

# Destroy all global variables created by this file
function _nh1backup.clean {
  unset _1BACKDIR _1BACKMAX
  unset -f 1backup 1unback 1backlist  _nh1backup.nextfile _nh1backup.maxcontrol
  unset -f _nh1backup.log _nh1backup.customvars 1backlist _nh1backup.names
  unset -f _nh1backup.info _1BACKGRP _nh1backup.bdir
}

function _nh1backup.names {
    if [ "$(find "$_1BACKDIR" -name '*-????-??-??*')" != "" ]
    then
        find "$_1BACKDIR" -name '*-????-??-??*' | xargs -n 1 basename | \
            sed 's/\(.*\)\(-....-..-..\)\(.*\)/\1/g' | sort | uniq | xargs
    fi
}

function _nh1backup.complete {
    _1verb "$(_1text "Enabling completion for 1backup.")"
    complete -W "$(_nh1backup.names)" 1backlist
}

# Load variables defined by user
function _nh1backup.customvars {
    if [[ $NORG_BACKUP_DIR ]]
    then
        _1BACKDIR="$NORG_BACKUP_DIR"
    fi
    if [[ $NORG_BACKUP_MAX ]]
    then
        _1BACKMAX="$NORG_BACKUP_MAX"
    fi
    if [[ $NORG_BACKUP_GROUP ]]
    then
        _1BACKGRP="$NORG_BACKUP_GROUP"
    fi
}

# Returns right backup dir
function _nh1backup.bdir {
    case "$_1BACKGRP" in
        'd')
            date "+$_1BACKDIR/%Y/%m/%d"
            ;;
        'w')
            date "+$_1BACKDIR/%Y/w%U"
            ;;
        'm')
            date "+$_1BACKDIR/%Y/%m"
            ;;
        'y')
            date "+$_1BACKDIR/%Y"
            ;;
        *)
            echo "$_1BACKDIR"
            ;;
    esac
}

function _nh1backup.info {
    	_1menuitem W NORG_BACKUP_DIR "$(_1text "Path for backups.")"
        _1menuitem W NORG_BACKUP_MAX "$(_1text "Max quantity of files to keep for each backup.")"
        _1menuitem W NORG_BACKUP_GROUP "$(printf \
            "$(_1text "Group backups by: day (%s), weekly (%s), month (%s), year (%s) or no-group (%s).")" \
            'd' 'w' 'm' 'y' 'n')"
}

function _nh1backup.log {
    local _NOW _L1 _L2 _L3
    _NOW=$(date "+%Y-%m-%d %X")
    mkdir -p "$_1UDATA/log"
    _L1="$_1UDATA/log/backup.txt"
    _L2="$_1BACKDIR/log.txt"
    _L3="$(_nh1backup.bdir)/log.txt"
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
    _DEST=$(_nh1backup.bdir)
    if [ $_1BACKMAX -gt 0 ]
    then
        _1verb "Scanning $_DEST/$_NAME-*"
        _OLD=($(ls --sort=time $_DEST/$_NAME-*))
        while [[ ${#_OLD[@]} -gt $_1BACKMAX ]]
        do
            _1verb "$(printf "$(_1text "There are %i backups. Max is %i. Removing %s.")" ${#_OLD[@]} $_1BACKMAX ${_OLD[0]})"
            if rm ${_OLD[0]}
            then
                _nh1backup.log "$(printf "$(_1text "Removed file %s from %s.")" ${_OLD[0]} $_DEST)"
            else    
                _nh1backup.log "$(printf "$(_1text "ERROR removing %s from %s... %i")" ${_OLD[0]} $_DEST $?)"
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
    _DEST=$(_nh1backup.bdir)
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
    local _NAME _TARGET _DEST _FILE _COMPL _COUNT _OLD _MSG _LMSG
    _NAME="$1"
    _TARGET="$2"
    _MSG=$(_1text "Running %s for %s, saving in %s...")

    _nh1backup.customvars

    if [ $# -eq 2 ]
    then
        if 1check 7z
        then        
            _FILE=$(_nh1backup.nextfile "$_NAME" "7z")
            _LMSG="$(printf "$_MSG" "7-zip" $_TARGET $_FILE)"
            _1verb "$LMSG"
            if 7z a "$_FILE" "$_TARGET"
            then
                _nh1backup.log "$LMSG"
            else
                _nh1backup.log "$(_1text "ERROR") $LMSG $?"
            fi
        elif 1check zip
        then
            _FILE=$(_nh1backup.nextfile "$_NAME" "zip")
            _LMSG="$(printf "$_MSG" "zip" $_TARGET $_FILE)"
            _1verb "$LMSG"
            if zip -r "$_FILE" "$_TARGET"
            then
                _nh1backup.log "$LMSG"
            else
                _nh1backup.log "$(_1text "ERROR") $LMSG $?"
            fi
        elif 1check tar
        then
            if 1check xz
            then
                _FILE=$(_nh1backup.nextfile "$_NAME" "tar.xz")
                _LMSG="$(printf "$_MSG" "$(_1text "tar with xz")" $_TARGET $_FILE)"
                _1verb "$LMSG"
                if tar -cJf "$_FILE" "$_TARGET"
                then
                    _nh1backup.log "$LMSG"
                else
                    _nh1backup.log "$(_1text "ERROR") $LMSG $?"
                fi
            elif 1check bzip2
            then
                _FILE=$(_nh1backup.nextfile "$_NAME" "tar.bz2")
                _LMSG="$(printf "$_MSG" "$(_1text "tar with bzip2")" $_TARGET $_FILE)"
                _1verb "$LMSG"
                if tar -cjf "$_FILE" "$_TARGET"
                then
                    _nh1backup.log "$LMSG"
                else
                    _nh1backup.log "$(_1text "ERROR") $LMSG $?"
                fi
            elif 1check gzip
            then
                _FILE=$(_nh1backup.nextfile "$_NAME" "tar.gz")
                _LMSG="$(printf "$_MSG" "$(_1text "tar with gzip")" $_TARGET $_FILE)"
                _1verb "$LMSG"
                if tar -czf "$_FILE" "$_TARGET"
                then
                    _nh1backup.log "$LMSG"
                else
                    _nh1backup.log "$(_1text "ERROR") $LMSG $?"
                fi
            else            
                _1text "Running tar without compression! Install gzip, bzip2 or xz!"
                _FILE=$(_nh1backup.nextfile "$_NAME" "tar")
                _LMSG="$(printf "$_MSG" "$(_1text "tar without compression")" $_TARGET $_FILE)"
                _1verb "$LMSG"
                if tar -cf "$_FILE" "$_TARGET"
                then
                    _nh1backup.log "$LMSG"
                else
                    _nh1backup.log "$(_1text "ERROR") $LMSG $?"
                fi
            fi
        else
            _1text "No compressor found. Try to install 7zip, zip or tar (with gzip, bzip2 or xz)."
        fi

        _nh1backup.maxcontrol "$_NAME"

    else
        printf "$(_1text "Usage: %s.")\n" "1backup <name> <directory>"
        printf "  - %s.\n" "$(_1text "Name: backup id")"
        printf "  - %s.\n" "$(_1text "Directory: target to backup")"
        printf "    %s.\n" "$(printf "(_1text "Backups are saved in %s")" $_1BACKDIR)"
    fi
}

# List all backups for one name (id)
# @param Name (id)
function 1backlist {
    _nh1backup.customvars
    if [ $# -eq 1 ]
    then
        find "$_1BACKDIR" -name "$1*"
    else
        _1text "Use 1backlist <name> to find all backups for <name>."
        echo -n "$(_1text "Names"): "
        _nh1backup.names
    fi
}