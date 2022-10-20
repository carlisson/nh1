#!/bin/bash
# @file backup.bashrc
# @brief Tools for backup

# GLOBALS

_1BACKDIR="$HOME/Backup"
_1BACKMAX=0
_1BACKGRP='m' # options: d,w,m,y,n

# @description Generate partial menu
_nh1backup.menu() {
  echo "___ $(_1text "Backup tools") ___"
  _1menuitem W 1backup "$(_1text "Make backup of a dir")"
  _1menuitem P 1unback "$(_1text "Restore a backup")"
  _1menuitem W 1backlist "$(_1text "List saved backups")"
  }

# @description Destroy all global variables created by this file
_nh1backup.clean() {
  unset _1BACKDIR _1BACKMAX _1BACKGRP
  unset -f 1backup 1unback 1backlist  _nh1backup.nextfile _nh1backup.maxcontrol
  unset -f _nh1backup.log _nh1backup.customvars 1backlist _nh1backup.names
  unset -f _nh1backup.info _1BACKGRP _nh1backup.bdir _nh1backup.clean
  unset -f _nh1backup.complete _nh1backup.menu _nh1backup.init
}

# @description List backup names from saved backups
# @stdout List of backup names
_nh1backup.names() {
    if [ "$(find "$_1BACKDIR" -name '*-????-??-??*')" != "" ]
    then
        find "$_1BACKDIR" -name '*-????-??-??*' | xargs -n 1 basename | \
            sed 's/\(.*\)\(-....-..-..\)\(.*\)/\1/g' | sort | uniq | xargs
    fi
}

# @description Autocomplete
_nh1backup.complete() {
    _1verb "$(_1text "Enabling completion for 1backup.")"
    complete -W "$(_nh1backup.names)" 1backlist
}

# @description Load variables defined by user
_nh1backup.customvars() {
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

# @description Initializing NH1 Backup
_nh1backup.init() {
	mkdir -p "$_1BACKDIR"
}

# @description Returns right backup dir
# @stdout Path where to save backups now
_nh1backup.bdir() {
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

# @description Information about possible custom vars
_nh1backup.info() {
    	_1menuitem W NORG_BACKUP_DIR "$(_1text "Path for backups.")"
        _1menuitem W NORG_BACKUP_MAX "$(_1text "Max quantity of files to keep for each backup.")"
        _1menuitem W NORG_BACKUP_GROUP "$(printf \
            "$(_1text "Group backups by: day (%s), weekly (%s), month (%s), year (%s) or no-group (%s).")" \
            'd' 'w' 'm' 'y' 'n')"
}

# @description Registry log message in 3 locals.
_nh1backup.log() {
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

# @description Controls max number of files
# @arg $1 string Name (id)
# @arg $2 string Directory for saved backups
_nh1backup.maxcontrol() {
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

# @description Returns next filename for base and extension
# @arg $1 string Name (id)
# @arg $2 string Extension
# @stdout File name for use in next backup operation
_nh1backup.nextfile() {
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

# @description Make backup of a directory
# @arg $1 string Name (id) for backup
# @arg $2 string Directory to backup
1backup() {
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

# @description List all backups for one name (id)
# @arg $1 string Name (id)
1backlist() {
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
