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
_1ANGELCOMMANDS=(builder engine now today)
_1ANGELDESCRIPTION="$(_1text "Angel template system")"
_1ANGELIGNORE=1 # ignore commands. Used to curly cut wings
_1ANGELBUILDER="NH1 $_1VERSION" # If you create a software based in NH1 and use 1angel, 
                                # you can update this var in your program.

# Private functions

# @description Special menu item
_nh1angel.item() {
    _1menuitem W 1angel "$_1ANGELDESCRIPTION"
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
		COMPREPLY=("help" "run" "show" "test")
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
    printf "  - help:    $(_1text "show this help")\n"
    printf "  - run:     $(_1text "apply a template")\n"
    printf "  - show:    $(_1text "show template content")\n"
    printf "  - test:    $(_1text "test arguments")\n"
    echo
}

# @description Run an internal command
# @arg $1 string Command
_1angel.command() {
    case "$1" in
        builder)
            echo "$_1ANGELBUILDER"
            ;;
        engine)
            echo "1angel (nh1)"
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
    _ARGS=$@

    # -=@=- Curly cut wings
    if [[ "$_LINE" =~ "-=@=-" ]]
    then
        if [ $_1ANGELIGNORE -eq 0 ]
        then
            _1ANGELIGNORE=1
        else
            _1ANGELIGNORE=0
        fi
        _LINE="$(echo $_LINE | 1remove "-=@=-")"
    fi
    if [ "$_1ANGELIGNORE" -eq 0 ]
    then
        return 0
    fi

    # Curly wings
    if [[ "$_LINE" =~ "-={" ]]
    then
        _LINE="$(echo $_LINE | sed "s/-={\([^}]*\)}=-//g")"
    fi

    if [[ "$_LINE" =~ "-=[" ]]
    then
        for _PAR in $_ARGS
        do
            if [[ "$_PAR" =~ = ]]
            then
                _VAR="$(echo $_PAR | sed 's/^\([a-zA-Z0-9]*\)=\(.*\)$/\1/')"
                _VAL="$(echo $_PAR | sed 's/^\([a-zA-Z0-9]*\)=\(.*\)$/\2/' | 1replace '/' '\/' 0 | 1replace "%20" " " 0)"
                if [ "$_VAR" != "$_VAL" ]
                then
                    _LINE=$(echo "$_LINE" | sed "s/-=\[$_VAR\( \([^]]*\)\)\?\]=-/$_VAL/g")
                fi
            fi
        done
    fi

    while [[ "$_LINE" =~ "-=!" ]]
    do
        _VAR="$(echo "$_LINE" | sed "s/\(.*\)-=!\([a-zA-Z0-9]*\)!=-\(.*\)/\2/")"
        _VAL="$(_1angel.command "$_VAR")"
        if [ $? -eq 0 ]
        then
            _LINE=$(echo "$_LINE" | 1replace "-=!$_VAR!=-" "$_VAL")
        else
            _LINE="$(echo $_LINE | 1remove "-=!$_VAR!=-")"
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
                        1angel run $_FILE $@ $_FLIN
                    done
                fi
            fi
            return 0
        fi
    fi

    # Cleaning line
    while [[ "$_LINE" =~ "-=[" ]]
    do
        _VAR="$(echo "$_LINE" | sed "s/\(.*\)-=\[\([a-zA-Z0-9]*\)\( \([^]]*\)\)\?\]=-\(.*\)/\2/")"
        _VAL="$(echo "$_LINE" | sed "s/\(.*\)-=\[\([a-zA-Z0-9]*\)\( \([^]]*\)\)\?\]=-\(.*\)/\4/")"
        if [ ! -z "$_VAL" ]
        then
            _LINE=$(echo "$_LINE" | sed "s/-=\[$_VAR\( \([^]]*\)\)\?\]=-/$_VAL/")
        else
            _LINE=$(echo "$_LINE" | 1replace "-=[$_VAR]=-" "$_VAR")
        fi
    done

    echo $_LINE
}

# @description Test usage
_1angel.test() {
  local _PAR _VAR _VAL _VFILE
  _VFILE="$1"
  shift
  1banner "$(_1text "Angel Test for $_VFILE")"
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
    local _line _lmax _AUX _VFILE _args
    
    _1ANGELIGNORE=1 # reset comment-flag
    _VFILE="$1"
    shift
    _lmax=$(wc -l <$_VFILE)
    _args="$(echo "$@ " | sed "s/=\([^=]\+\) /=\1~~+~~/g" \
        | 1replace " " "%20" 0 | 1replace "~~+~~" " " 0)"

    for _line in $(seq $_lmax)
    do
        _1angel.apply "$(sed -n "$_line"p "$_VFILE")" "$_args"
    done
}

# @description Show template information
_1angel.show() {
    local _MSG _LINE _INCL _AUX
    _1ANGELIGNORE=1
    _INCL=""
    _1menuheader "$(_1text "Showing template information")"

    while read -r _LINE
    do
        if [[ "$_LINE" =~ "-=@=-" ]]
        then
            if [ $_1ANGELIGNORE -eq 0 ]
            then
                _1ANGELIGNORE=1
            else
                _1ANGELIGNORE=0
            fi
        fi
        if [ "$_1ANGELIGNORE" -eq 0 ]
        then
            echo $_LINE
        else
            while [[ "$_LINE" =~ "-={" ]]
            do
                _MSG="$(echo $_LINE | sed "s/\(.*\)-={\([^}]*\)\(.*\)}=-/\2/")"
                _1message info "$_MSG"
                _LINE="$(echo $_LINE | sed "s/\(.*\)-={\([^}]*\)\(.*\)}=-/\1/")" # removing comment marks
            done
            while [[ "$_LINE" =~ "-=(" ]]
            do
                _MSG="$(echo $_LINE | sed "s/\(.*\)-=(\([^)]*\)\(.*\))=-/\2/")"
                _AUX="$(echo "$_MSG" | sed "s/\([^ ]*\) \(.*\)$/\1/")"
                printf "$(_1text "Includes variable: %s")\n" "$(1tint "$_AUX")"
                _AUX="$(echo "$_MSG" | sed "s/\([^ ]*\) \(.*\)$/\2/")"
                if [[ "$_AUX" =~ ^= ]]
                then
                   printf " -- $(_1text "using variable %s to get the included angel file")\n" "$(1tint "$(echo "$_AUX" | sed "s/^=//")")"
                else
                   printf " -- $(_1text "using this angel file: %s")\n" "$(1tint "$_AUX")"
                    _INCL="$_INCL $_AUX"
                fi
                _LINE="$(echo $_LINE | sed "s/\(.*\)-=(\([^)]*\)\(.*\))=-/\1/")" # removing comment marks
            done
            while [[ "$_LINE" =~ "-=[" ]]
            do
                _VAR="$(echo "$_LINE" | sed "s/\(.*\)-=\[\([a-zA-Z0-9]*\)\( \([^]]*\)\)\?\]=-\(.*\)/\2/")"
                _VAL="$(echo "$_LINE" | sed "s/\(.*\)-=\[\([a-zA-Z0-9]*\)\( \([^]]*\)\)\?\]=-\(.*\)/\4/")"
                if [ ! -z "$_VAL" ]
                then
                    printf "$(_1text "Varibale %s with default value %s")\n" "$(1tint $_1COLOR $_VAR)" "$_VAL"
                else
                    printf "$(_1text "Varibale %s without default value")\n" "$(1tint $_1COLOR $_VAR)"
                fi
                _LINE="$(echo $_LINE | sed "s/\(.*\)-=\[\([a-zA-Z0-9]*\)\( \([^]]*\)\)\?\]=-\(.*\)/\1 \5/")" # removing comment marks
            done
        fi
    done <$1
    for _AUX in $_INCL
    do
        echo
        _1angel.show $_AUX
    done
}

# Public functions

# @description Main command for Angel Templates
# @arg $1 string Command
# @arg $2 string Attributions
1angel() {
    local _COM

    if [ $# -ge 1 ]
    then
        _COM="$1"
        shift
        case $_COM in
            run)
                _1angel.go "$@"
                ;;
            show)
                _1angel.show "$1"
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
