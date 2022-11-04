#!/bin/bash
# @file cron.bashrc
# @brief Functions for automation

# GLOBALS
_1CRONDIR="$_1UDATA/cron"
_1CRONTIMES=(hour day week month year always start)
_1CRONENABLED=0 #true

# Private functions

# @description Generates partial menu
_nh1cron.menu() {
  _1menuheader "Cron Section"
  # _1menutip Optional complementar instruction
  # _1menuitem X command "Description"
  _1menuitem X 1cronset "$(_1text "Set a cron entry")"
  _1menuitem X 1crondel "$(_1text "Remove a cron entry")"
  _1menuitem X 1cronlist "$(_1text "List all cron entries")"
  _1menuitem X 1cron "$(_1text "Check and run due commands")"
  _1menuitem X 1crond "$(_1text "Run cron in daemon mode")"
  _1menuitem X 1run "$(_1text "Run a command now")"
}

# @description Destroys all global variables created by this file
_nh1cron.clean() {
  # unset variables
  unset _1CRONDIR _1CRONTIMES _1CRPONENABLED
  unset -f _nh1cron.menu _nh1cron.complete _nh1cron.init
  unset -f _nh1cron.info _nh1cron.customvars _nh1cron.clean
  unset -f _nh1cron.listtimes 1cronset 1crondel 1cronlist
  unset -f 1run _nh1cron.now _nh1cron.tick 1cron 1crond
}

# @description Autocompletion instructions
_nh1cron.complete() {
    _1verb "$(_1text "Enabling complete for cron module.")"
}

# @description Set global vars from custom vars (config file)
_nh1cron.customvars() {
  _1customvar NORG_CRON _1CRONENABLED number
  _1customvar NORG_CRON_DIR _1CRONDIR
}

# @description General information about variables and customizing
_nh1cron.info() {
    _1menuitem W NORG_CRON_DIR "$(_1text "Path for cron rules")"
    _1menuitem W NORG_CRON "$(_1text "Turn on (0) or off (1) cron checkings")"
}

# @description Creates paths and copy initial files
_nh1cron.init() {
    local _TIM
    mkdir -p "$_1CRONDIR"

    for _TIM in "${_1CRONTIMES[@]}"
    do
        touch "$_1CRONDIR/$_TIM.cron" #commands to run
        touch "$_1CRONDIR/$_TIM.status" #latest execution or PID
    done
}

# @description Returns all times possible for cron
_nh1cron.listtimes() {
    echo -n "${_1CRONTIMES[@]}"
}

# @description Returns condition based on time of cron
# @arg $1 string Time of cron
_nh1cron.now() {
    local _STA
    case "$1" in
        hour)
            _STA="$(date "+%Y-%m-%d %Hh")"
            ;;
        day)
            _STA="$(date "+%Y-%m-%d")"
            ;;
        week)
            _STA="$(date "+%Y#%W")"
            ;;
        month)
            _STA="$(date "+%Y-%m")"
            ;;
        year)
            _STA="$(date "+%Y")"
            ;;
        always)
            _STA="run"
            ;;
        start)
            _STA="done"
            ;;
    esac
    echo "$_STA"
}

# @description Set latest run in status
# @arg $1 string Time of cron
# @arg $2 string Command ID
_nh1cron.tick() {
    local _STA
    _STA="$(_nh1cron.now "$1")"
    if [ "$_STA" = "run" ]
    then
        1run "$1" "$2"
    else
        _1db.set "$_1CRONDIR" "status" "$1" "$2" "$_STA"
        _1message bg "$(printf "$(_1text "Command %s finished at %s.")" "$2" "$(date)")"
    fi
}

# Alias-like

# Public functions

# @description Add or update a command to cron
# @arg $1 string Time of cron: hour, day...
# @arg $2 string Command ID
# @arg $3 string Command
# @exitcode 0 It works
# @exitcode 1 Unknown cron time
1cronset() {
    local _TIM _CID
    if [ $# -ge 3 ]
    then
        if [ -f "$_1CRONDIR/$1.cron" ]
        then
            _TIM="$1"
            _CID="$2"
            shift 2
   	        _1db.set "$_1CRONDIR" "cron" "$_TIM" "$_CID" "$*"
        else
            _1message error "$(_1text "Unknown cron time")"
            return 1
        fi
    else
        _1message "$(printf "$(_1text "Usage: %s [%s] [%s] [%s].")" "1cronset" "$(_1text "cron time")" "$(_1text "command id")" "$(_1text "command")")"
        _1message "$(_1text "Time values: ") $(_nh1cron.listtimes)"
    fi
    return 0
}

# @description Remove a command from cron
# @arg $1 string Time of cron: hour, day...
# @arg $2 string Command ID
1crondel() {
    local _TIM _CID
    if [ $# -eq 2 ]
    then
       if [ -f "$_1CRONDIR/$1.status" ]
        then
   	        _1db.set "$_1CRONDIR" "cron" "$1" "$2"
        fi
 
         if [ -f "$_1CRONDIR/$1.cron" ]
        then
   	        _1db.set "$_1CRONDIR" "cron" "$1" "$2"
        else
            _1message error "$(_1text "Unknown cron time.")"
            return 1
        fi
    else
        _1message "$(printf "$(_1text "Usage: %s [%s] [%s].")" "1crondel" "$(_1text "cron time")" "$(_1text "command id")")"
        _1message "$(_1text "Time values: ") $(_nh1cron.listtimes)"
    fi
    return 0
}

# @descritpion List all cron configurations
1cronlist() {
    local _TIM _CMD _PTH _VAL
    for _TIM in "${_1CRONTIMES[@]}"
    do
        _1menuheader "$_TIM"
        for _CMD in $(_1db.show "$_1CRONDIR" "cron" "$_TIM" list)
        do
            _PTH=$(_1db.get "$_1CRONDIR" "cron" "$_TIM" "$_CMD")
            _VAL=$(_1db.get "$_1CRONDIR" "status" "$_TIM" "$_CMD")
            _1menuitem W "$_CMD" "$_VAL ($_PTH)"
        done
    done
}

# @description Run a command
# @arg $1 string Wich time is the command (optional)
# @arg $2 string Command ID
# @exitcode 0 It works
# @exitcode 1 Command not found
# @exitcode 2 Unknown cron time
1run() {
    local _TIM _CMD
    case $# in
        2)
            _TIM="$1"
            _CMD=$(_1db.get "$_1CRONDIR" "cron" "$_TIM" "$2")
            if [ $? -eq 0 ]
            then
                eval "$_CMD" &> /dev/null
                _nh1cron.tick "$_TIM" "$2"
            else
                _1message error "$(_1text "Command not found")"
                return 1
            fi
            ;;    
        1)
            _TIM="$(grep -l "$1" $_1CRONDIR/*.cron | sed 's/\(.*\)\/\([a-z]*\)\.cron/\2/' | head -1)"
            if [ -n "$_TIM" ]
            then
                _CMD=$(_1db.get "$_1CRONDIR" "cron" "$_TIM" "$1")
                if [ $? -eq 0 ]
                then
                    eval "$_CMD" &> /dev/null
                    _nh1cron.tick "$_TIM" "$1"
                else
                    _1message error "$(_1text "Command not found")"
                    return 1
                fi
            else
                _1message error "$(_1text "Unknown cron time.")"
                return 2
            fi
            ;;
        0)
            _1message "$(printf "$(_1text "Usage: %s [%s] [%s].")" "1run" "$(_1text "cron time (optional)")" "$(_1text "command id")")"
            ;;            
    esac
    return 0
}

# @description Check and run commands from cron
# @arg $1 string Mode: normal/force/teste. Default: normal
1cron() {
    local _MOD _TIM _CMD _NOW _STA _MSG
    if [ $# -eq 1 ]
    then
        _MOD="$1"
    else
        _MOD="normal"
    fi

    if [ "$_MOD" = "normal" -a $_1CRONENABLED -eq 1 ]
    then
        return 0
    fi

    _1verb "$(_1text "Starting cron function.")"
    for _TIM in $(_nh1cron.listtimes)
    do
        for _CMD in $(_1db.show "$_1CRONDIR" "cron" "$_TIM" list)
        do
            _STA=$(_1db.get "$_1CRONDIR" "status" "$_TIM" "$_CMD")
            _NOW=$(_nh1cron.now "$_TIM")
            if [ "$_STA" != "$_NOW" ]
            then
                _MSG="$(printf "$(_1text "Run (frequency: %s) the command %s.")" "$_TIM" "$_CMD")"
                if [ "$_MOD" = "test" ]
                then
                    _1message info "$_MSG"
                else
                    _1verb "$_MSG"
                    1run "$_TIM" "$_CMD" &
                fi
            fi
        done
    done
    _1verb "$(_1text "Cron finished.")"
}

# @description Run cron as a daemon
1crond() {
    if [ "$_1CRONENABLED" -eq 0 ]
    then
        while true
        do
            1cron
            _1message
            sleep 50
            if [ $? -gt 0 ] # If sleep is interrupted, abort 1crond
            then
                return $?
            fi
        done
    fi
}