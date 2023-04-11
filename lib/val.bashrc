#!/bin/bash
# @file val.bashrc
# @brief Value validators

# GLOBALS
_1VALS=(cpf email name)
_1VALDESCRIPTION="$(_1text "Value validators")"

# Private functions

# @description Special menu item
_nh1val.item() {
    _1menuitem W 1val "$_1VALDESCRIPTION"
}

# @description Destroys all global variables created by this file
_nh1val.clean() {
  # unset variables
  unset -f _nh1val.item _nh1val.clean _nh1val.complete.val _nh1val.complete
  unset -f _nh1val.customvars _nh1val.info _nh1val.init _nh1val.usage
  unset _1VALS _1VALDESCRIPTION
}

# @description Completion for 1val
# @stdout A list of apps
_nh1val.complete.val() {
    local _SCO _COM
  	COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
		COMPREPLY=("${_1VALS[@]}")
    fi
}

# @description Autocompletion instructions
_nh1val.complete() {
    complete -F _nh1val.complete.val 1val
}

# @description Set global vars from custom vars (config file)
_nh1val.customvars() {
  #_1customvar NORG_CUSTOM_VAR _1LOCALVAR
  false
}

# @description General information about variables and customizing
_nh1val.info() {
    false
}

# @description Creates paths and copy initial files
_nh1val.init() {
  #_1menuitem W NORG_CUSTOM_VAR "$(_1text "Description")"
  false
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1val.usage() {
    printf "$(_1text "Usage: %s [%s] [%s]")\n" \
        "1val" "$(_1text "option or validation")" "$(_1text "text")"
    printf "  $(_1text "Validations and options"):\n"
    printf "  - help:    $(_1text "show this help")\n"
    printf "  - cpf:     $(_1text "Brazilian civic card number")\n"
    printf "  - email:   $(_1text "E-mail address")\n"
    printf "  - name:    $(_1text "Person name")\n"
    echo
}

# Alias-like

# Public functions

# @description Validate a string
# @arg $1 string Desired validation.
# @arg $2 string String to validate
# @exitcode 0 String is ok
# @exitcode 1 String is not valid
# @stdout Transformed string
1val() {
    local _COM _TXT _AUX
    if [ "$1" = "help" ]
    then
        _nh1val.usage
        return 0
    fi
    if [ $# -gt 1 ]
    then
        _COM=$1
        shift
        _TXT="$@"
        case $_COM in
            cpf)
                # check if CPF is only number
                _AUX=$(echo "$_TXT" | wc -m)
                echo "AUX: $_AUX"
                if [ $_AUX -gt 12 ]
                then
                    _AUX=$(echo "$_TXT" | sed "s/^\([0-9]\{3\}\)\.\([0-9]\{3\}\)\.\([0-9]\{3\}\)-\([0-9]\{2\}\)$/\1\2\3\4/")
                    if [ "$_TXT" = "$_AUX" ]
                    then
                        return 1
                    else
                        _TXT=$_AUX
                    fi
                fi                
        		if [ $(echo "$_TXT" | wc -m) -lt 12 ]
		        then
                    printf "0%.0s" $(seq $((12 - _AUX)) )
                    _TXT=$_AUX
                fi
                # First digit
                _AUX=$((${_TXT:0:1}*10 + ${_TXT:1:1}*9 + ${_TXT:2:1}*8 + ${_TXT:3:1}*7 + ${_TXT:4:1}*6 + 
                    ${_TXT:5:1}*5 + ${_TXT:6:1}*4 + ${_TXT:7:1}*3 + ${_TXT:8:1}*2))
                _AUX=$(( (_AUX*10 % 11) % 10))
                if [ "$_AUX" != "${_TXT:9:1}" ]
                then
                    return 1
                fi
                # Second digit
                _AUX=$((${_TXT:0:1}*11 + ${_TXT:1:1}*10 + ${_TXT:2:1}*9 + ${_TXT:3:1}*8 + ${_TXT:4:1}*7 + 
                    ${_TXT:5:1}*6 + ${_TXT:6:1}*5 + ${_TXT:7:1}*4 + ${_TXT:8:1}*3 + ${_TXT:9:1}*2))
                _AUX=$(( (_AUX*10 % 11) % 10))
                if [ "$_AUX" = "${_TXT:10:1}" ]
                then
                    printf "%s.%s.%s-%s" ${_TXT:0:3} ${_TXT:3:3} ${_TXT:6:3} ${_TXT:9:2}
                    return 0
                else
                    return 1
                fi
                ;;
            email)
            	if [[ "$_TXT" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]
                then
                    echo $_TXT
                    return 0
                else
                    return 1
                fi
                ;;
            name)
                if [ "$_TXT" = "" ]
                then
                    return 1
                fi
                _AUX="$(1morph unaccent,upper $_TXT | tr -d ' .0-9A-Z')"
                if [ "$_AUX" = "" ]
                then
                    echo $_TXT
                    return 0
                else
                    return 1
                fi
                ;;

        esac
    fi
    _nh1val.usage
    return 1
}
