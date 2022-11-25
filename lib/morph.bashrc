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
    local _NUM _INT _MOD _WRD
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
            elif [ $_NUM -lt 20 ]
            then
                case $_NUM in
                    10) _1text "ten" ;;
                    11) _1text "eleven" ;;
                    12) _1text "twelve" ;;
                    13) _1text "thirteen" ;;
                    14) _1text "fourteen" ;;
                    15) _1text "fiveteen" ;;
                    16) _1text "sixteen" ;;
                    17) _1text "seventeen" ;;
                    18) _1text "eighteen" ;;
                    19) _1text "nineteen" ;;
                esac
            elif [ $_NUM -lt 100 ]
            then
                _INT=$((_NUM / 10))
                _MOD=$((_NUM % 10))
                
                if [ $_MOD -eq 0 ]
                then
                    case $_INT in
                        2) _1text "twenty" ;;
                        3) _1text "thirty" ;;
                        4) _1text "forty" ;;
                        5) _1text "fifty" ;;
                        6) _1text "sixty" ;;
                        7) _1text "seventy" ;;
                        8) _1text "eighty" ;;
                        9) _1text "ninety" ;;
                    esac
                else
                    _WRD=$(1words $_MOD)
                    case $_INT in
                        2) printf "$(_1text "twenty-%s")" "$_WRD" ;;
                        3) printf "$(_1text "thirty-%s")" "$_WRD" ;;
                        4) printf "$(_1text "forty-%s")" "$_WRD" ;;
                        5) printf "$(_1text "fifty-%s")" "$_WRD" ;;
                        6) printf "$(_1text "sixty-%s")" "$_WRD" ;;
                        7) printf "$(_1text "seventy-%s")" "$_WRD" ;;
                        8) printf "$(_1text "eighty-%s")" "$_WRD" ;;
                        9) printf "$(_1text "ninety-%s")" "$_WRD" ;;
                    esac
                fi
            elif [ $_NUM -lt 1000 ]
            then
                _INT=$((_NUM / 100))
                _MOD=$((_NUM % 100))
                
                if [ $_MOD -eq 0 ]
                then
                    case $_INT in
                        1) _1text "one hundred" ;;
                        2) _1text "two hundred" ;;
                        3) _1text "three hundred" ;;
                        4) _1text "four hundred" ;;
                        5) _1text "five hundred" ;;
                        6) _1text "six hundred" ;;
                        7) _1text "seven hundred" ;;
                        8) _1text "eight hundred" ;;
                        9) _1text "nine hundred" ;;
                    esac
                else
                    _WRD=$(1words $_MOD)
                    _1verb "$_NUM is $_INT * 100 + $_MOD. $_MOD=$_WRD"
                    case $_INT in
                        1) printf "$(_1text "one hundred and %s")" "$_WRD" ;;
                        2) printf "$(_1text "two hundred and %s")" "$_WRD" ;;
                        3) printf "$(_1text "three hundred and %s")" "$_WRD" ;;
                        4) printf "$(_1text "four hundred and %s")" "$_WRD" ;;
                        5) printf "$(_1text "five hundred and %s")" "$_WRD" ;;
                        6) printf "$(_1text "six hundred and %s")" "$_WRD" ;;
                        7) printf "$(_1text "seven hundred and %s")" "$_WRD" ;;
                        8) printf "$(_1text "eight hundred and %s")" "$_WRD" ;;
                        9) printf "$(_1text "nine hundred and %s")" "$_WRD" ;;
                    esac
                fi
            elif [ $_NUM -eq 1000 ]
            then
                _1text "one thousand"
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