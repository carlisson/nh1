#!/bin/bash
# @file morph.bashrc
# @brief String transformations

# GLOBALS

# Private functions

# @description Generates partial menu
_nh1morph.menu() {
  _1menuheader "$(_1text "Morph Section (strings)")"
  _1menutip "$(_1text "String transformation utilities")"
  _1menuitem P 1words "$(_1text "Converts integer to words")"
}

# @description Destroys all global variables created by this file
_nh1morph.clean() {
  # unset variables
  unset -f _nh1morph.menu _nh1morph.complete _nh1morph.init
  unset -f _nh1morph.info _nh1morph.customvars _nh1morph.clean
  unset -f _nh1morph.usage
}

# @description Autocompletion instructions
_nh1morph.complete() {
    false
}

# @description Set global vars from custom vars (config file)
_nh1morph.customvars() {
  #_1customvar NORG_CUSTOM_VAR _1LOCALVAR
  false
}

# @description General information about variables and customizing
_nh1morph.info() {
    false
}

# @description Creates paths and copy initial files
_nh1morph.init() {
  #_1menuitem W NORG_CUSTOM_VAR "$(_1text "Description")"
  false
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1morph.usage() {
  case $1 in
    words)
        printf "$(_1text "Usage: %s [%s]")\n" "1$1" "$(_1text "number")"
        ;;
    *)
      false
      ;;
  esac
}

# Alias-like

# Public functions

# @description Converts integer into words
# @arg $1 int Number
# @stdout Converted number (string)
1words() {
    local _NUM
    if [ $# -gt 0 ]
    then
        _NUM=$1
        if [ $_NUM -eq $_NUM 2>/dev/null ]
        then
            if [ $_NUM -lt 10 ]
            then
                case $_NUM in
                    0) _1text "zero" ;;
                    1) _1text "one" ;;
                    2) _1text "two" ;;
                    3) _1text "three" ;;
                    4) _1text "four" ;;
                    5) _1text "five" ;;
                    6) _1text "six" ;;
                    7) _1text "seven" ;;
                    8) _1text "eight" ;;
                    9) _1text "nine" ;;
                esac
            else
                _1text "many"
            fi
        else
            _1message error "$(_1text "Argument is not an integer number.")"
        fi
    else
        _nh1morph.usage words
    fi
}