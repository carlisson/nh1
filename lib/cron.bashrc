#!/bin/bash
# @file cron.bashrc
# @brief Functions for automation

# GLOBALS
_1CRONDIR="$_1UDATA/cron"
_1CRONTIMES=(hour day week month year always start)

# Private functions

# @description Generates partial menu
_nh1cron.menu() {
  _1menuheader "Cron Section"
  # _1menutip Optional complementar instruction
  # _1menuitem X command "Description"
  _1menuitem P 1cronset "$(_1text "Set a cron entry")"
  _1menuitem P 1crondel "$(_1text "Remove a cron entry")"
  _1menuitem P 1cronlist "$(_1text "List all cron entries")"
  _1menuitem P 1cron "$(_1text "Check and run due commands")"
  _1menuitem P 1run "$(_1text "Run a command now")"
}

# @description Destroys all global variables created by this file
_nh1cron.clean() {
  # unset variables
  unset _1CRONDIR
  unset -f _nh1cron.menu _nh1cron.complete _nh1cron.init
  unset -f _nh1cron.info _nh1cron.customvars _nh1cron.clean
  unset -f _nh1cron.listtimes 1cronset
}

# @description Autocompletion instructions
_nh1cron.complete() {
    _1verb "$(_1text "Enabling complete for cron module.")"
}

# @description Set global vars from custom vars (config file)
_nh1cron.customvars() {
  _1customvar NORG_CRON_DIR _1CRONDIR
}

# @description General information about variables and customizing
_nh1cron.info() {
    _1menuitem W NORG_CRON_DIR "$(_1text "Path for cron rules")"
}

# @description Creates paths and copy initial files
_nh1cron.init() {
    local _TIM
    mkdir -p "$_1CRONDIR"

    for _TIM in "${_1CRONTIMES[@]}"
    do
        touch "$_1CRONDIR/$_TIM.cron"
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