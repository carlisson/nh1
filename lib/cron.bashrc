#!/bin/bash
# @file cron.bashrc
# @brief Functions for automation

# GLOBALS
_1CRONDIR="$_1UDATA/cron"
_1CRONTIMES=(hour day week month year always start)
_1CRONENABLED=1 #true

# Private functions

# @description Generates partial menu
_nh1cron.menu() {
  _1menuheader "$(_1text "Cron Section")"
  # _1menutip Optional complementar instruction
  # _1menuitem X command "Description"
  _1menuitem X 1cronset "$(_1text "Set a cron entry")"
  _1menuitem X 1crondel "$(_1text "Remove a cron entry")"
  _1menuitem X 1cronlist "$(_1text "List all cron entries")"
  _1menuitem X 1cron "$(_1text "Check and run due commands")"
  _1menuitem X 1crond "$(_1text "Run cron in daemon mode")"
  _1menuitem X 1every "$(_1text "Run a command every x seconds, minutes or hours")"
  _1menuitem X 1run "$(_1text "Run a command now")"
}

# @description Destroys all global variables created by this file
_nh1cron.clean() {
  # unset variables
  unset _1CRONDIR _1CRONTIMES _1CRONENABLED
  unset -f _nh1cron.menu _nh1cron.complete _nh1cron.init
  unset -f _nh1cron.info _nh1cron.customvars _nh1cron.clean
  unset -f _nh1cron.listtimes 1cronset 1crondel 1cronlist
  unset -f 1run _nh1cron.now _nh1cron.tick 1cron 1crond
  unset -f _nh1cron.interrupt _nh1cron.startup
  unset -f _nh1cron.crongroup
}

# @description Autocompletion instructions
_nh1cron.complete() {
    _1verb "$(_1text "Enabling complete for cron module.")"
}

# @description Set global vars from custom vars (config file)
_nh1cron.customvars() {
  if [ $_1LIBMODE -eq 0 ]
  then
    _1customvar NORG_CRON _1CRONENABLED boolean
  else
    _1CRONENABLED=0
  fi
  _1customvar NORG_CRON_DIR _1CRONDIR
}

# @description General information about variables and customizing
_nh1cron.info() {
    _1menuitem W NORG_CRON_DIR "$(_1text "Path for cron rules")"
    _1menuitem W NORG_CRON "$(_1text "Turn on (true) or off (false) cron checkings")"
}

# @description Creates paths and copy initial files
_nh1cron.init() {
    local _TIM
    mkdir -p "$_1CRONDIR"

    for _TIM in "${_1CRONTIMES[@]}"
    do
        touch "$_1CRONDIR/$_TIM.cron" #commands to run
        touch "$_1CRONDIR/$_TIM.status" #latest execution
        touch "$_1CRONDIR/$_TIM.pid" #PID for running processes
    done

    _nh1cron.startup
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
        _1db.set "$_1CRONDIR" "pid" "$1" "$2"
        _1message bg "$(printf "$(_1text "Command %s finished at %s.")" "$2" "$(date)")"
    fi
}

# @description Usage instructions
# @arg $1 string Command
_nh1cron.usage() {
    case $1 in
        every)
            printf "$(_1text "Usage: %s [%s] <%s> <%s>")\n" "1$1" "$(_1text "(optional) \"quiet\" for quiet mode")" "$(_1text "Interval")" "$(_1text "Command ID")"
            ;;
    esac
}

# @description Routine to run if interrupted
_nh1cron.interrupt() {
    local _PID
    for _PID in $(cat "$_1CRONDIR/*.pid" | sed 's/^\(.*\)=\([0-9]*\)$/\2 /g')
    do
        _1verb "$(printf "$(_1text "Finishing command %s.")" $_PID )"
        kill $_PID
    done
}

# @description Run all commands for given "time"
# @arg $1 string Mode: normal/force/teste.
# @arg $2 string Cron time (group)
_nh1cron.crongroup() {
    local _TIM _MOD _STA _NOW _MSG _CMD _PID
    _MOD="$1"
    _TIM="$2"
    for _CMD in $(_1db.show "$_1CRONDIR" "cron" "$_TIM" list)
    do
        _STA=$(_1db.get "$_1CRONDIR" "status" "$_TIM" "$_CMD")
        if [ -z "$_STA" ]
        then
            _STA="none"
        fi
        _NOW=$(_nh1cron.now "$_TIM")
        if [ "$_STA" != "$_NOW" -o "$_MOD" = "force" ]
        then
            _PID=$(_1db.get "$_1CRONDIR" "pid" "$_TIM" "$_CMD")

            _1verb "$(printf "$(_1text "Command %s executed at %s. Running now (%s) again. %i")" "$_CMD" "$_STA" "$_NOW" "$_PID")"

            if [ -n "$_PID" ]
            then
                if ps -p $_PID > /dev/null
                then
                    _1message info "$(printf "$(_1text "Command %s is still running (PID %i).")" "$_CMD" "$_PID")"
                else
                    _1verb "$(printf "$(_1text "Command %s is not more running.")" "$_CMD")"
                    _1db.set "$_1CRONDIR" "pid" "$_TIM" "$_CMD"
                    _PID=
                fi
            fi

            if [ -z "$_PID" ]
            then
                _MSG="$(printf "$(_1text "Run (frequency: %s) the command %s.")" "$_TIM" "$_CMD")"
                if [ "$_MOD" = "test" ]
                then
                    _1message info "$_MSG"
                else
                    _1verb "$_MSG"
                    1run "$_TIM" "$_CMD" &
                    _1db.set "$_1CRONDIR" "pid" "$_TIM" "$_CMD" "$!"
                fi
            fi
        fi
    done
}

# @description Commands for time "start"
_nh1cron.startup() {
    local _CMD
    if [ "$_1CRONENABLED" -gt 0 ]
    then
        for _CMD in $(_1db.show "$_1CRONDIR" "cron" "start" list)
        do
            _nh1cron.crongroup "force" "start"
        done
    fi
    1cron
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
	_1before
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
	_1before
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
	_1before
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

# @description Run a command every x seconds (or other time unity)
# @arg $1 string "quiet" for quiet mode (optional)
# @arg $2 string Interval
# @arg $3 string Command
1every() {
    local _NUM _UNI _CMD _MOD
    _MOD="normal"
    if [ $# -eq 3 ]
    then
        _MOD="quiet"
        shift
    fi
    if [ $# -ne 2 ]
    then
        _nh1cron.usage every
        return 0
    fi
    _CMD="$2"
    if [[ $1 =~ ^[0-9]+$ ]]
    then
        _NUM=$1
        _UNI="s"
    else
        _NUM=$(echo $1 | sed 's/\(\ *\)//g' | sed 's/^\([0-9]*\)\([a-zA-Z]*\)\(.*\)/\1/')
        _UNI=$(echo $1 | sed 's/\(\ *\)//g' | sed 's/^\([0-9]*\)\([a-zA-Z]\)\(.*\)/\2/')
    fi
    while $(true)
    do
        $_CMD
        if [ "$_MOD" = "quiet" ]
        then
            sleep "$_NUM""$_UNI"
        else
            case "$_UNI" in
                s)
                    1timer $_1COLOR "$_CMD" $_NUM
                    ;;
                m)
                    1timer $_1COLOR "$_CMD" 0 $_NUM
                    ;;
                h)
                    1timer $_1COLOR "$_CMD" 0 0 $_NUM
                    ;;
            esac
        fi
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
                if [ $? -gt 0 ]
                then
                    _nh1cron.interrupt
                fi
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
                    if [ $? -gt 0 ]
                    then
                        _nh1cron.interrupt
                    fi
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
    local _MOD _TIM
    if [ $# -eq 1 ]
    then
        _MOD="$1"
    else
        _MOD="normal"
    fi

    if [ "$_MOD" = "normal" -a $_1CRONENABLED -eq 0 ]
    then
        return 0
    fi

    _1verb "$(_1text "Starting cron function.")"
    for _TIM in $(_nh1cron.listtimes)
    do
        _nh1cron.crongroup "$_MOD" "$_TIM"
    done
    _1verb "$(_1text "Cron finished.")"
}

# @description Run cron as a daemon
1crond() {
    local _PID
    if [ "$_1CRONENABLED" -eq 0 ]
    then
        while true
        do
            1cron
            _1message
            sleep 50
            if [ $? -gt 0 ] # If sleep is interrupted, abort 1crond
            then
                _nh1cron.interrupt
                return $?
            fi
        done
    fi
}