#!/bin/bash
# @file ui.bashrc
# @brief Generic user Interface for dialogs

# GLOBALS

# Private functions

# @description Generates partial menu
_nh1ui.menu() {
  _1menuheader "$(_1text "User Interface")"
  # _1menutip Optional complementar instruction
  _1menuitem X 1uisays "$(_1text "Show information")"
  _1menuitem X 1uiconfirm "$(_1text "Ask confirmation from user")"
  _1menuitem X 1uiask "$(_1text "Ask from user to get a string")"
}

# @description Destroys all global variables created by this file
_nh1ui.clean() {
  # unset variables
  unset -f _nh1ui.menu _nh1ui.complete _nh1ui.init _nh1ui.info
  unset -f _nh1ui.customvars _nh1ui.clean _nh1ui.usage 1uisays
  unset -f 1uiconfirm 1uiask
}

# @description Autocompletion instructions
_nh1ui.complete() {
    _1verb "$(_1text "Enabling completion for ui module.")"
}

# @description Set global vars from custom vars (config file)
_nh1ui.customvars() {
#  _1customvar NORG_CUSTOM_VAR _1LOCALVAR
    false
}

# @description General information about variables and customizing
_nh1ui.info() {
#    _1verb "$(_1text "Listing user variables")"
    false
}

# @description Creates paths and copy initial files
_nh1ui.init() {
  #_1menuitem W NORG_CUSTOM_VAR "$(_1text "Description")"
  false
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1ui.usage() {
  case $1 in
    says|confirm|ask)
        printf "$(_1text "Usage: %s [%s]")\n" "1ui$1" "Message"
        ;;
    *)
      false
      ;;
  esac
}

# Alias-like

# Public functions

# @description Show information to user
# @arg $1 Message to show
1uisays() {
    local _MSG
    if [ $# -gt 0 ]
    then
        _MSG="$*"
    else
        _nh1ui.usage "says"
        return 0
    fi
    if 1check zenity
    then
        zenity --info --text="$_MSG"
    fi
}

# @description Ask user for confirmation
# @arg $1 Question to user
# @exitcode 0 User confirm
# @exitcode 1 User says no
# @exitcode 2 Other situation
1uiconfirm() {
    local _MSG
    if [ $# -gt 0 ]
    then
        _MSG="$*"
    else
        _nh1ui.usage "confirm"
        return 2
    fi
    if 1check zenity
    then
        zenity --question --text="$_MSG"
        return $?
    fi
}

# @description Ask user for a text
# @arg $1 Question to user
# @stdout String writen by user
1uiask() {
    local _MSG _RSP
    if [ $# -gt 0 ]
    then
        _MSG="$*"
    else
        _nh1ui.usage "ask"
        return 2
    fi
    if 1check zenity
    then
        _RSP=$(zenity --entry --text="$_MSG")
        echo $_RSP
    fi
}