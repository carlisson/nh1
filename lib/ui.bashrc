#!/bin/bash
# @file ui.bashrc
# @brief Generic user Interface for dialogs

# GLOBALS
_1UIDIALOGS=(yad zenity kdialog Xdialog gxmessage whiptail dialog xmessage)
_1UIDIALOGSIZE="7 70"
_1UITITLE="NH1 $_1VERSION"

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
  unset -f 1uiconfirm 1uiask _nh1ui.confirm _nh1ui.ask
  unset -f _nh1ui.choose
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

# @description Question user using read
# @arg $1 Message, question
# @exitcode 0 User confirm
# @exitcode 1 User says no
_nh1ui.confirm() {
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
_nh1ui.ask() {
    local _RSPx
    echo -n "$1 " >/dev/stderr
    read _RSP
    echo $_RSP
}

# @description Choose best dialog system
_nh1ui.choose() {
    local _DIA
    
    for _DIA in ${_1UIDIALOGS[@]}
    do
        if 1check -s "$_DIA"
        then
            echo "$_DIA"
            return 0
        fi
    done
    echo "none"
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

    case "$(_nh1ui.choose)" in
        dialog)
            dialog --title="$_1UITITLE" --msgbox "$_MSG" $_1UIDIALOGSIZE
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
1uiconfirm() {
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
            dialog --title="$_1UITITLE" --yesno "$_MSG" $_1UIDIALOGSIZE
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
            _nh1ui.confirm "$_MSG"
            return $?
            ;;
    esac
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

    case "$(_nh1ui.choose)" in
        dialog)
            _RSP=$(dialog --title="$_1UITITLE" --inputbox "$_MSG" $_1UIDIALOGSIZE  3>&1 1>&2 2>&3)
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
            _RSP=$(Xdialog --title="$_1UITITLE" --inputbox "$_MSG" $_1UIDIALOGSIZE)
            ;;
        yad)
            _RSP=$(yad --title="$_1UITITLE" --entry --text="$_MSG")
            ;;
        zenity)
            _RSP=$(zenity --title="$_1UITITLE" --entry --text="$_MSG")
            ;;
        *)
            _RSP=$(_nh1ui.ask "$_MSG")
            ;;
    esac
    echo $_RSP
}