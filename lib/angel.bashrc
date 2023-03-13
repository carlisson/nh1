#!/bin/bash
# @file angel.bashrc
# @brief Angel template system
# @description
#     Template system for NH1
#      * -=[name]=- variable substitution
#      * -={text}=- comment
#      * -=@=- multiline comment
#      * -=!com!- internal command
#      * -=(name file)=- includes a external file. a list of attributions
#        can be passed in var "name", so inclusion will do loop.
#      * usage: 1angel [command] var=value < angel-input-file > output-file

# GLOBALS
_1ANGELCOMMANDS=(nh1 now today)
_1ANGELDESCRIPTION="$(_1text "Angel template system")"
_1ANGELIGNORE=1 # ignore commands. Used to curly cut wings

# Private functions

# @description Special menu item
_nh1angel.item() {
    _1menuitem W 1angel "$_1UIDESCRIPTION"
}

# @description Destroys all global variables created by this file
_nh1angel.clean() {
  # unset variables
  unset _1LOCALVAR
  unset -f _nh1angel.item _nh1angel.complete _nh1angel.init
  unset -f _nh1angel.info _nh1angel.customvars _nh1angel.clean
  unset -f _nh1angel.usage _nh1angel.complete.angel _1angel.go
  unset -f _1angel.test _1angel.getValue
}

# @description UI Completion
# @stdout A list of commands
_nh1angel.complete.angel() {
    local _SCO _COM
  	COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
		COMPREPLY=("go" "help" "test")
    fi
}

# @description Autocompletion instructions
_nh1angel.complete() {
    complete -F _nh1angel.complete.angel 1angel
}

# @description Set global vars from custom vars (config file)
_nh1angel.customvars() {
  #_1customvar NORG_CUSTOM_VAR _1LOCALVAR
  false
}

# @description General information about variables and customizing
_nh1angel.info() {
    #_1verb "$(_1text "Listing user variables")"
    false
}

# @description Creates paths and copy initial files
_nh1angel.init() {
  #_1menuitem W NORG_CUSTOM_VAR "$(_1text "Description")"
  false
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1angel.usage() {
    printf "$(_1text "Usage: %s [%s] [%s]* < [%s] > [%s]")\n" "1angel" "$(_1text "Command")" "$(_1text "Attributions (var=value)")" "$(_1text "angel input file")" "$(_1text "output file")"
    printf "  - go:      $(_1text "apply a template")\n"
    printf "  - help:    $(_1text "show this help")\n"
    printf "  - test:    $(_1text "test arguments")\n"
    echo
}

# @description Run an internal command
# @arg $1 string Command
_1angel.command() {
    case "$1" in
        nh1)
            echo "NH1 $_1VERSION"
            ;;
        now)
            date "+%H:%M"
            ;;
        today)
            date "+%Y-%m-%d"
            ;;
        *)
            return 1
            ;;
    esac
    return 0;
}

# @description Returns value for given variable, from a argument list
# @arg $1 string Variable name
# @arg $2 string List of attributions
_1angel.getValue() {
    local _K _E _V
    _K=$1
    shift
    _E="$* "
    _V="$(echo "$_E" | sed "s/\(.*\)$_K=\([^ ]*\)\(.*\)/\2/" )"
    if [ ! "$_V" = "$_E" ]
    then
        echo $_V
        return 0
    else
        return 1
    fi
}

# @description Apply variables in one line
# @arg $1 string Text line
# @arg $2 string Attributions
_1angel.apply() {
    local _PAR _FILE _VAR _VAL _FLIN _I _TOTAL _FVAR _FVAL _ARGS _FREF
    local _LINE="$1"
    shift
    _ARGS="$* "

    # -=@=- Curly cut wings
    if [[ "$_LINE" =~ "-=@=-" ]]
    then
        if [ $_1ANGELIGNORE -eq 0 ]
        then
            _1ANGELIGNORE=1
        else
            _1ANGELIGNORE=0
        fi
        _LINE="$(echo $_LINE | sed "s/-=@=-//")"
    fi
    if [ "$_1ANGELIGNORE" -eq 0 ]
    then
        return 0
    fi

    if [[ "$_LINE" =~ "-={" ]]
    then
        _LINE="$(echo $_LINE | sed "s/-={\([^}]*\)}=-//g")"
    fi
    if [[ "$_LINE" =~ "-=[" ]]
    then
        for _PAR in "$@"
        do
            _VAR="$(echo $_PAR | sed 's/^\([a-zA-Z0-9]*\)=\(.*\)$/\1/')"
            _VAL="$(echo $_PAR | sed 's/^\([a-zA-Z0-9]*\)=\(.*\)$/\2/')"
            if [ "$_VAR" != "$_VAL" ]
            then
                _LINE=$(echo "$_LINE" | sed "s/-=\[$_VAR\]=-/$_VAL/g")
            fi
        done
    fi
    while [[ "$_LINE" =~ "-=!" ]]
    do
        _VAR="$(echo "$_LINE" | sed "s/\(.*\)-=!\([a-zA-Z0-9]*\)!=-\(.*\)/\2/")"
        _VAL="$(_1angel.command "$_VAR")"
        if [ $? -eq 0 ]
        then
            _LINE=$(echo "$_LINE" | sed "s/-=!$_VAR!=-/$_VAL/")
        else
            _LINE="$(echo $_LINE | sed "s/-=!$_VAR!=-//")"
        fi
    done
    if [[ "$_LINE" =~ "-=(" ]]
    then
        _VAR="$(echo "$_LINE" | sed "s/^-=(\([a-zA-Z0-9]*\) \([^ )]*\))=-\(.*\)/\1/")"
        _FILE="$(echo "$_LINE" | sed "s/^-=(\([a-zA-Z0-9]*\) \([^ )]*\))=-\(.*\)/\2/")"
        _LINE="$(echo $_LINE | sed "s/-=(\([^)]*\))=-//")"

        if [[ "$_FILE" =~ ^= ]]
        then
            _FREF="$(echo "$_FILE" | sed 's/=\(.*\)/\1/')"

        else
            _FREF="none"
        fi

        if [ -f "$_FILE" -o "$_FREF" != "none" ]
        then
            _FVAL="$(_1angel.getValue "$_VAR" $_ARGS)"
            if [ ! -z "$_FVAL" ]
            then
                if [ -f "$_FVAL" ]
                then
                    _TOTAL=$(cat "$_FVAL" | wc -l)
                    for _I in $(seq 1 $_TOTAL)
                    do
                        _FLIN=$(sed -n "$_I"p "$_FVAL")
                        if [ $_FREF != "none" ]
                        then
                            _FILE=$(_1angel.getValue "$_FREF" $_FLIN)
                        fi
                        1angel go $@ $_FLIN < $_FILE
                    done
                fi
            fi
            return 0
        fi
    fi
    echo $_LINE
}

# @description Test usage
_1angel.test() {
  local _PAR _VAR _VAL
  1banner "$(_1text "Angel Test")"
  for _PAR in "$@"
  do
    _VAR="$(echo $_PAR | sed 's/^\([a-zA-Z0-9]*\)=\(.*\)$/\1/')"
    _VAL="$(echo $_PAR | sed 's/^\([a-zA-Z0-9]*\)=\(.*\)$/\2/')"
    if [ "$_VAR" = "$_VAL" ]
    then
        _1message warning "$(printf "$(_1text "Error in %s")\n" "$_VAR")"
    else
        if [ -f "$_VAL" ]
        then
            _1menuheader "$(printf "$(_1text "File: %s for name %s")" "$_VAL" "$_VAR")"
            cat "$_VAL"
            _1menuheader "-----"
        else
            _1menuitem W $_VAR "$_VAL"
        fi
    fi
  done  
}

# @description Applies a template
_1angel.go() {
    local _line

    while read -r _line
    do
        _1angel.apply "$_line" $@
    done
}

# Public functions

# @description Main command for Angel Templates
# @arg $1 string Command
# @arg $2 string Attributions
1angel() {
    local _COM

    if [ $# -gt 1 ]
    then
        _COM="$1"
        shift
        case $_COM in
            go)
                _1angel.go "$@"
                ;;
            test)
                _1angel.test "$@"
                ;;
            *)
                _nh1angel.usage
                ;;
        esac
    else
        _nh1angel.usage
    fi
}
