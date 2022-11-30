#!/bin/bash
# @file ui.bashrc
# @brief Generic user Interface for dialogs

# GLOBALS
_1UIDIALOGS=(yad zenity kdialog Xdialog gxmessage whiptail dialog)
_1UICONSOLE=(whiptail dialog)
_1UIGUI=2 # Gui level: 0: none; 1: console; 2: all dialogs
_1UIDIALOGSIZE="12 70"
_1UITITLE="NH1 $_1VERSION"
_1UIDESCRIPTION="$(_1text "User interface for simple user interaction")"

# Private functions

# @description Generate partial menu
_nh1ui.menu() {
    false
}

# @description Generates special menu
_nh1ui.item() {
    _1menuitem W 1ui "$_1UIDESCRIPTION"
}

# @description Destroys all global variables created by this file
_nh1ui.clean() {
  # unset variables
  unset _nh1ui.description
  unset -f _nh1ui.complete _nh1ui.init _nh1ui.info
  unset -f _nh1ui.customvars _nh1ui.clean _nh1ui.usage _nh1ui.say
  unset -f _nh1ui.confirm _nh1ui.ask _nh1ui.confirm _nh1ui.ask
  unset -f _nh1ui.choose _nh1ui.simpleask _nh1ui.simpleconfirm
  unset -f 1ui _nh1ui.select _nh1ui.simpleselect
}

# @description Autocompletion instructions
_nh1ui.complete() {
    _1verb "$(_1text "Enabling completion for ui module.")"
}

# @description Set global vars from custom vars (config file)
_nh1ui.customvars() {
  _1customvar NORG_UI_LEVEL _1UIGUI
}

# @description General information about variables and customizing
_nh1ui.info() {
  _1menuitem W NORG_UI_LEVEL "$(_1text "GUI level. 0: none; 1: console only; 2: including GUI (default)")"
}

# @description Creates paths and copy initial files
_nh1ui.init() {
    false
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1ui.usage() {
    printf "$(_1text "Usage: %s [%s] [%s]")\n" "1ui" "$(_1text "Command")" "$(_1text "Message")"
    printf "  - ask:     $(_1text "ask a question and receive user entry")\n"
    printf "  - confirm: $(_1text "ask user for confirmation")\n"
    printf "  - say:     $(_1text "show a message to user")\n"
    echo
    printf "  $(_1text "1ui will work with %s.")\n" $(_nh1ui.choose)
    echo
}

# @description Question user using read
# @arg $1 Message, question
# @exitcode 0 User confirm
# @exitcode 1 User says no
_nh1ui.simpleconfirm() {
    local _RSPx
    1tint "$1 (Y/N) "
    read _RSP
    case "$_RSP" in
        Y|y|yes|YES|Yes)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# @description Question user using read
# @arg $1 Message, question
# @exitcode 0 User confirm
# @exitcode 1 User says no
_nh1ui.simpleask() {
    local _RSPx
    echo -n "$1 " >/dev/stderr
    read _RSP
    echo $_RSP
}

# @description Shows a menu with options to user choose one
# @arg $1 string Message to show
# @arg $2 string Every argument
# @stdout string choonsen option
# @exitcode 0 User choose
# @exitcode 1 User cancel
_nh1ui.simpleselect() {
    local _OPT _CNT _ARG _OCO

    _1menuheader "$1"
    shift

    _CNT=0

	_OCO=$_1MENUCOL
	_1MENUCOL=5
    for _ARG in "$@"
    do
        _CNT=$((_CNT+1))
        _1menuitem W $_CNT "$_ARG"
    done
    _1MENUCOL=$_OCO

    1tint "$(_1text "Enter the number of your choice"): "
    read _OPT
    if [ $_OPT -gt 0 -a $_OPT -le $_CNT  2>/dev/null ]
    then
        echo $_OPT
        return 0
    else
        echo 0
        return 1
    fi
}

# @description Choose best dialog system
_nh1ui.choose() {
    local _DIA
    
    case $_1UIGUI in
        1)
            for _DIA in ${_1UICONSOLE[@]}
            do
                if 1check -s "$_DIA"
                then
                    echo "$_DIA"
                    return 0
                fi
            done
            ;;
        2)
            for _DIA in ${_1UIDIALOGS[@]}
            do
                if 1check -s "$_DIA"
                then
                    echo "$_DIA"
                    return 0
                fi
            done
            ;;
    esac
    echo "none"
}

# @description Show information to user
# @arg $1 Message to show
_nh1ui.say() {
    local _MSG
    if [ $# -gt 0 ]
    then
        _MSG="$*"
    else
        _nh1ui.usage "says"
        return 0
    fi

    case "$(_nh1ui.choose)" in
        dialog)
            dialog --title "$_1UITITLE" --msgbox "$_MSG" $_1UIDIALOGSIZE
            ;;
        gxmessage)
            gxmessage -title "$_1UITITLE" -buttons Ok:0 -default Ok -nearmouse "$_MSG"
            ;;
        kdialog)
            kdialog --title="$_1UITITLE" --msgbox "$_MSG"
            ;;
        whiptail)
            whiptail --title "$_1UITITLE" --msgbox "$_MSG" $_1UIDIALOGSIZE
            ;;
        Xdialog)
            Xdialog --title="$_1UITITLE" --msgbox "$_MSG" $_1UIDIALOGSIZE
            ;;
        xmessage)
            xmessage -title "$_1UITITLE" -buttons Ok:0 -default Ok -nearmouse "$_MSG"
            ;;
        yad)
            yad --title="$_1UITITLE" --info --text="$_MSG"
            ;;
        zenity)
            zenity --title="$_1UITITLE" --info --text="$_MSG"
            ;;
        *)
            1tint "$_MSG"
            echo
            ;;
    esac
}

# @description Ask user for confirmation
# @arg $1 Question to user
# @exitcode 0 User confirm
# @exitcode 1 User says no
# @exitcode 2 Other situation
_nh1ui.confirm() {
    local _MSG
    if [ $# -gt 0 ]
    then
        _MSG="$*"
    else
        _nh1ui.usage "confirm"
        return 2
    fi

    case "$(_nh1ui.choose)" in
        dialog)
            dialog --title "$_1UITITLE" --yesno "$_MSG" $_1UIDIALOGSIZE
            return $?
            ;;
        gxmessage)
            gxmessage -title "$_1UITITLE" -buttons Ok:0,Cancel:1 -default Ok -nearmouse "$_MSG"
            return $?
            ;;
        kdialog)
            kdialog --title="$_1UITITLE" --yesno "$_MSG"
            return $?
            ;;
        whiptail)
            whiptail --title "$_1UITITLE" --yesno "$_MSG" $_1UIDIALOGSIZE
            return $?
            ;;
        Xdialog)
            Xdialog --title="$_1UITITLE" --yesno "$_MSG" $_1UIDIALOGSIZE
            return $?
            ;;
        xmessage)
            xmessage -title "$_1UITITLE" -buttons Ok:0,Cancel:1 -default Ok -nearmouse "$_MSG"
            return $?
            ;;
        yad)
            yad --title="$_1UITITLE" --question --text="$_MSG"
            return $?
            ;;
        zenity)
            zenity --title="$_1UITITLE" --question --text="$_MSG"
            return $?
            ;;
        *)
            _nh1ui.simpleconfirm "$_MSG"
            return $?
            ;;
    esac
}

# @description Ask user for a text
# @arg $1 Question to user
# @stdout String writen by user
_nh1ui.ask() {
    local _MSG _RSP
    if [ $# -gt 0 ]
    then
        _MSG="$*"
    else
        _nh1ui.usage "ask"
        return 2
    fi

    case "$(_nh1ui.choose)" in
        dialog)
            _RSP=$(dialog --title "$_1UITITLE" --inputbox "$_MSG" $_1UIDIALOGSIZE  3>&1 1>&2 2>&3)
            ;;
        gxmessage)
            _RSP=$(gxmessage -title "$_1UITITLE" -entry "$_MSG")
            ;;
        kdialog)
            _RSP=$(kdialog --title="$_1UITITLE" --inputbox "$_MSG")
            ;;
        whiptail)
            _RSP=$(whiptail --title "$_1UITITLE" --inputbox "$_MSG" $_1UIDIALOGSIZE  3>&1 1>&2 2>&3)
            ;;
        Xdialog)
            _RSP=$(Xdialog --stdout --title="$_1UITITLE" --inputbox "$_MSG" $_1UIDIALOGSIZE)
            ;;
        yad)
            _RSP=$(yad --title="$_1UITITLE" --entry --text="$_MSG")
            ;;
        zenity)
            _RSP=$(zenity --title="$_1UITITLE" --entry --text="$_MSG")
            ;;
        *)
            _RSP=$(_nh1ui.simpleask "$_MSG")
            ;;
    esac
    echo $_RSP
}

# @description Shows a menu with options to user choose one
# @arg $1 string Message to show
# @arg $2 string Every argument
# @stdout string choonsen option
_nh1ui.select() {
    local _MSG _OPT _AUX _COU
    local _ENU # Enumberated list: 1 one 2 two
    local _ENB # Enum block: one:1,two:2
    local _ENA # Enum array: 1)one 2)two
    _MSG="$1"
    shift

    _ENU=""
    _ENB="Cancel:0"
    _ENA=""
    _COU=0
    for _AUX in "$@"
    do
        _AUX=$(1stresc "$_AUX" | tr ':,' '..')
        _COU=$((_COU+1))
        _ENU="$_ENU $_COU $_AUX"
        _ENB="$_ENB,$_AUX:$_COU"
        _ENA="$_ENA $_COU)$_AUX"
    done

    case "$(_nh1ui.choose)" in
        dialog)
            _OPT=$(dialog --title "$_1UITITLE" --menu "$_MSG" $_1UIDIALOGSIZE 12 $_ENU 3>&1 1>&2 2>&3)
            ;;
        gxmessage)
            gxmessage -title "$_1UITITLE" -buttons $_ENB -default Ok -nearmouse "$_MSG"
            _OPT=$?
            ;;
        kdialog)
            _OPT=$(kdialog --title="$_1UITITLE" --menu "$_MSG" $_ENU)
            ;;
        whiptail)
            _OPT=$(whiptail --title "$_1UITITLE" --menu "$_MSG" $_1UIDIALOGSIZE 5 $_ENU 3>&1 1>&2 2>&3)
            ;;
        Xdialog)
            _OPT=$(Xdialog --stdout --title="$_1UITITLE" --combobox "$_MSG" $_1UIDIALOGSIZE $_ENA | cut -d\) -f 1)
            ;;
        yad)
            _OPT=$(yad --title="$_1UITITLE" --list --column='#' --column="$(_1text Option)" $_ENU | cut -d\| -f 1)
            ;;
        zenity)
            _OPT=$(zenity --title="$_1UITITLE" --list --column='#' --column="$(_1text Option)" $_ENU)
            ;;
        *)
            _OPT=$(_nh1ui.simpleselect "$_MSG" "$@" 3>&1 1>&2 2>&3)
            ;;
    esac
    echo $_OPT
}

# Alias-like

# Public functions

# @description Main command for User Interface
# @arg $1 string Help or type of function
# @arg $2 string Message to show
1ui() {
    case "$1" in
        say)
            _nh1ui.say "$2"
            ;;
        ask)
            _nh1ui.ask "$2"
            ;;
        confirm)
            _nh1ui.confirm "$2"
            return $?
            ;;
        menu)
            shift
            _nh1ui.select "$@"
            ;;
        *)
            _nh1ui.usage
            ;;
    esac
}