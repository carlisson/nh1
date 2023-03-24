#!/bin/bash
# @file morph.bashrc
# @brief String transformations

# GLOBALS
_1MORPHS=(cursive cyrillic escape greek leet lower migu phone randdel randdup randsn randssc randuc reverse rotvow randspl sedscape super unaccent updown upper xthicc)

# Without exotic alphabets
_1MORPHLATIN=(escape leet lower migu randdel randdup randsn randssc randuc reverse rotvow randspl unaccent upper)
# Private functions

# @description Generates partial menu
_nh1morph.menu() {
  _1menuheader "$(_1text "Morph Section (strings)")"
  _1menutip "$(_1text "String transformation utilities")"
  _1menuitem X 1morph "$(_1text "Transform a string")"
  _1menuitem X 1words "$(_1text "Converts integer to words")"
}

# @description Destroys all global variables created by this file
_nh1morph.clean() {
  # unset variables
  unset -f _nh1morph.menu _nh1morph.complete _nh1morph.init
  unset -f _nh1morph.info _nh1morph.customvars _nh1morph.clean
  unset -f _nh1morph.usage 1morph _nh1morph.complete.morph
}

# @description Completion for 1morph
# @stdout A list of apps
_nh1morph.complete.morph() {
    local _SCO _COM
  	COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
		COMPREPLY=("${_1MORPHS[@]}")
    fi
}

# @description Autocompletion instructions
_nh1morph.complete() {
    complete -F _nh1morph.complete.morph 1morph
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
    morph)
        printf "$(_1text "Usage: %s [%s] [%s]")\n" "1$1" "$(_1text "transformation")" "$(_1text "text")"
        printf "  - $(_1text "Available transformations: %s.")\n" "$(echo -n ${_1MORPHS[@]})"
        printf "  - $(_1text "You can apply more transformations using comma (ex: %s)")\n" "unaccent,leet"
        ;;
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

# @description Transforms a string
# @arg $1 string Desired transformation. List to see all availables.
# @arg $2 string String to transform
1morph() {
    local _MORPH _AUX1 _AUX2 _TEXT
    _TEXT=""
    if [ $# -gt 0 ]
    then
        _MORPH="$1"
        shift
    else
        _nh1morph.usage morph
        return 0
    fi
    if [ $# -gt 0 ]
    then
        _TEXT=$(echo $*)
    else
        read _TEXT
    fi
    if echo $_MORPH | grep -q ','
    then
        for _AUX1 in $(echo $_MORPH | tr ',' ' ')
        do
            _TEXT=$(1morph $_AUX1 $_TEXT)
        done
        echo $_TEXT
        return 0
    fi
    if [ "$_TEXT" != "" ]
    then
        case "$_MORPH" in
            cursive)
                echo $_TEXT | 1tr 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz' '𝓐𝓪𝓑𝓫𝓒𝓬𝓓𝓭𝓔𝓮𝓕𝓯𝓖𝓰𝓗𝓱𝓘𝓲𝓙𝓳𝓚𝓴𝓛𝓵𝓜𝓶𝓝𝓷𝓞𝓸𝓟𝓹𝓠𝓺𝓡𝓻𝓢𝓼𝓣𝓽𝓤𝓾𝓥𝓿𝓦𝔀𝓧𝔁𝓨𝔂𝓩𝔃'
                ;;
            cyrillic)
                echo $_TEXT | 1tr "BbCcDdEeFfGgIiJjLlNnPpRrSsTtUuVvYyZz" "БбЦцДдЭэФфГгИиЖжЛлНнПпРрCcТтУуВвЫыЗз"
                ;;
            escape)
                echo $_TEXT | tr "\\\ \t?!\${}" "/__..S++"
                ;;
            greek)
                echo $_TEXT | 1tr "abCcDdeFfGgiLlmnOoPpRrTtUuz" "αβΞξΔδεΦφΓγιΛλμνΩωΠπΡρΘθΥυζ"
                ;;
            leet)
                echo $_TEXT | tr "aAbBeEgGiIlLoOsSzZ" "44883366!!77005522"
                ;;
            lower)
                echo $_TEXT | tr '[:upper:]' '[:lower:]'
                ;;
            migu) # Miguxês
                echo $_TEXT | 1replace "qu" "k" 0 | 1replace "ês" "eix" 0 | 1replace "ões" "oinx" 0 | \
                    sed 's/\([aeo]\)u\([ \.?!]\)/\1w\2/g' | \
                    sed 's/[áÁ]/ah/g;s/[éÉêÊ]/eh/g;s/[íÍ]/ih/g;s/[óÓôÔ]/oh/g;s/[úÚ]/uh/g' | \
                    sed 's/ão/aum/g;s/inh\([oa]\)/eenh\1/g;' | \
                    sed 's/o\([ \.?!]\)/u\1/g;s/e\([ \.?!]\)/i\1/g' | tr 's' 'x' | \
                    sed 's/c\([aou]\)/k\1/g' | sed 's/c\([ei]\)/x\1/g' | 1tr 'ç' 'x'
                ;;
            phone) # replacing using number-equivalence from simple phone
                echo $_TEXT | tr ' ,.!?;:aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ+-=/' '11111122222233333344444455555566666677777777888888999999990000'
                ;;
            randdel) # Random deletion
                _AUX1=$(1dice "${#_TEXT}")
                echo ${_TEXT:0:_AUX1-1}${_TEXT:_AUX1}
                ;;
            randdup) # Random duplicate
                _AUX1=$(1dice "${#_TEXT}")
                echo ${_TEXT:0:_AUX1}${_TEXT:_AUX1-1}
                ;;
            randsn) # Random substitute to number
                _AUX1=$(1dice "${#_TEXT}")
                echo ${_TEXT:0:_AUX1-1}$(($(1d10)-1))${_TEXT:_AUX1}
                ;;
            randspl) # Random split
                _AUX1=$(1dice "${#_TEXT}")
                echo ${_TEXT:_AUX1}${_TEXT:0:_AUX1}
                ;;
            randssc) # Random substitute to special char
                _AUX1=$(1dice "${#_TEXT}")
                echo ${_TEXT:0:_AUX1-1}$(1spchar)${_TEXT:_AUX1}
                ;;
            randuc) # Random upper case
                _AUX1=$(1dice "${#_TEXT}")
                echo ${_TEXT:0:_AUX1-1}$(echo ${_TEXT:_AUX1-1:1} | tr '[:lower:]' '[:upper:]')${_TEXT:_AUX1}
                ;;
            reverse)
                echo $_TEXT | rev
                ;;
            rotvow) # Rotate vowels
                case $(1d6) in
                    1)
                        echo $_TEXT | tr 'aeiou' 'euioa'
                        ;;
                    2)
                        echo $_TEXT | tr 'aeiou' 'eaoui'
                        ;;
                    3)
                        echo $_TEXT | tr 'aeiou' 'aeoui'
                        ;;
                    4) 
                        echo $_TEXT | tr 'aeiou' 'eioau'
                        ;;
                    5)
                        echo $_TEXT | tr 'aeiou' 'eauio'
                        ;;
                    6)
                        echo $_TEXT | tr 'aeiou' 'oaiue'
                        ;;
                esac
                ;;
            sedscape)
                echo $_TEXT | 1replace '\' '\\' 0 | 1replace '/' '\/' 0 | 1replace '[' '\[' 0 | 1replace ']' '\]' 0 | \
                    1replace '$' '\$' 0 | 1replace '.' '\.' 0 | 1replace '\*' '\\*' 0 | 1replace '^' '\^' 0
                ;;
            super) # Superscript
                echo $_TEXT | 1tr 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789' 'ᴬᵃᴮᵇᶜᶜᴰᵈᴱᵉᶠᶠᴳᵍᴴʰᴵᶦᴶʲᴷᵏᴸˡᴹᵐᴺⁿᴼᵒᴾᵖᵠᵠᴿʳˢˢᵀᵗᵁᵘⱽᵛᵂʷˣˣʸʸᶻᶻ⁰¹²³⁴⁵⁶⁷⁸⁹'
                ;;
            unaccent)
                echo $_TEXT | iconv -f utf8 -t ascii//TRANSLIT
                ;;
            updown) # Upside down
                _TEXT=$(1morph reverse $_TEXT)
                echo $_TEXT | 1tr 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789' 'ⱯɑBpCcDqEԍᖶɻᘓმHμIᴉᒉᒉKĸΓɼWwИuOobb⥀dᖉʁƧƨꓕϝꓵnΛʌMʍXx⅄λZz0Ɩᘕ3ત૨୧⌋8მ'
                ;;
            upper)
                echo $_TEXT | tr '[:lower:]' '[:upper:]'
                ;;
            xthicc) # Extra Thicc
                echo $_TEXT | 1tr 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz' '卂卂乃乃匚匚ᗪᗪ乇乇千千ᎶᎶ卄卄丨丨ﾌﾌҜҜㄥㄥ爪爪几几ㄖㄖ卩卩ɊɊ尺尺丂丂ㄒㄒㄩㄩᐯᐯ山山乂乂ㄚㄚ乙乙'
                ;;
        esac
    else
        _nh1morph.usage morph
    fi

}

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
