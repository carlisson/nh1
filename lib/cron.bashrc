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
  _1menuitem P 1cron "$(_1text "Check and run due commands")"
  _1menuitem P 1crond "$(_1text "Run cron in daemon mode")"
  _1menuitem P 1run "$(_1text "Run a command now")"
}

# @description Destroys all global variables created by this file
_nh1cron.clean() {
  # unset variables
  unset _1CRONDIR _1CRONTIMES _1CRPONENABLED
  unset -f _nh1cron.menu _nh1cron.complete _nh1cron.init
  unset -f _nh1cron.info _nh1cron.customvars _nh1cron.clean
  unset -f _nh1cron.listtimes 1cronset 1crondel 1cronlist
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
        _1message "$(printf "$(_1text "Usage %s [%s] [%s] [%s].")" "1cronset" "$(_1text "cron time")" "$(_1text "command id")" "$(_1text "command")")"
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
            _1message error "$(_1text "Unknown cron time")"
            return 1
        fi
    else
        _1message "$(printf "$(_1text "Usage %s [%s] [%s].")" "1crondel" "$(_1text "cron time")" "$(_1text "command id")")"
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