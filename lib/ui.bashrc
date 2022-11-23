#!/bin/bash
# @file ui.bashrc
# @brief Generic user Interface for dialogs

# GLOBALS
#?

# Private functions

# @description Generates partial menu
_nh1ui.menu() {
  _1menuheader "$(_1text "User Interface")"
  # _1menutip Optional complementar instruction
  _1menuitem P 1uisays "$(_1text "Show information")"
  _1menuitem P 1uiconfirm "$(_1text "Ask confirmation from user")"
  _1menuitem P 1uiask "$(_1text "Ask from user to get a string")"
}

# @description Destroys all global variables created by this file
_nh1ui.clean() {
  # unset variables
  unset _1LOCALVAR
  unset -f _nh1ui.menu _nh1ui.complete _nh1ui.init _nh1ui.info
  unset -f _nh1ui.customvars _nh1ui.clean _nh1ui.usage
}

# @description Autocompletion instructions
_nh1ui.complete() {
    _1verb "$(_1text "Enabling completion for ui module.")"
}

# @description Set global vars from custom vars (config file)
_nh1ui.customvars() {
#  _1customvar NORG_CUSTOM_VAR _1LOCALVAR
    echo
}

# @description General information about variables and customizing
_nh1ui.info() {
#    _1verb "$(_1text "Listing user variables")"
    echo
}

# @description Creates paths and copy initial files
_nh1ui.init() {
  #_1menuitem W NORG_CUSTOM_VAR "$(_1text "Description")"
  echo
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1ui.usage() {
  case $1 in
    *)
      echo
      ;;
  esac
}

# Alias-like

# Public functions
