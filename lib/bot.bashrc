#!/bin/bash
# @file bot.bashrc
# @brief Bot to send messages

# GLOBALS
_1BOTTELEGRAM=0
_1BOTDBPATH="$_1UDATA/bots"
_1BOTDBEXT="bt"
_1BOTTYPES=(telegram)

# Private functions

# @description Generates partial menu
_nh1bot.menu() {
  _1menuheader "$(_1text "Bots")"
  # _1menutip Optional complementar instruction
  # _1menuitem X command "Description"
}

# @description Destroys all global variables created by this file
_nh1bot.clean() {
  # unset variables
  unset _1BOTDBPATH _1BOTDBEXT
  unset -f _nh1bot.menu _nh1bot.complete _nh1bot.complete.bots _nh1bot.init
  unset -f _nh1bot.info _nh1bot.customvars _nh1bot.clean
  unset -f _nh1bot.usage
}

# @description Autocompletion instructions
_nh1bot.complete.bots() {
    local _SCO _COM
  	COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
		COMPREPLY=("${_1BOTTYPES[@]}")
    fi
}

# @description Autocompletion instructions
_nh1bot.complete() {
    complete -F _nh1bot.complete.bots 1bot
}

# @description Set global vars from custom vars (config file)
_nh1bot.customvars() {
  _1customvar NORG_BOT_TELEGRAM _1BOTTELEGRAM
}

# @description General information about variables and customizing
_nh1bot.info() {
  _1menuitem W NORG_BOT_TELEGRAM "$(_1text "Token for Telegram bot. Get it from @BotFather")"
}

# @description Creates paths and copy initial files
_nh1bot.init() {
  mkdir -p "$_1BOTDBPATH"
  touch "$_1BOTDBPATH/telegram.$_1BOTDBEXT"
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1bot.usage() {
    printf "$(_1text "Usage: %s %s [%s] [%s]")\n" "1bot" "$(_1text "type")" "$(_1text "Command")" "$(_1text "Other options")"
    printf "  - telegram $(_1text "works as a Telegram bot")\n"
    echo
    echo "$(_1text "Commands"):"
    printf "  - group-list %s\n" "$(_1text "list new groups for telegram bot")"
    printf "  - group-add [%s] [%s] %s\n" "$(_1text "Group name")" "$(_1text "Group ID")" "$(_1text "Save a group")"
    printf "  - group-del [%s] %s\n" "$(_1text "Group name")" "$(_1text "Delete a group")"
    printf "  - say [%s] [%s] %s\n" "$(_1text "Group name")" "$(_1text "message")" "$(_1text "Send a message")"
    echo
}

_1bot.missing() {
    _1message error "$(printf "$(_1text "%s for %s is missing!")" $2 $1)"
    _nh1bot.info
}

_1bot.db() {
    _1db "$_1BOTDBPATH" "$_1BOTDBEXT" "$@"
    return $?
}

_1bot.db.get() {
    _1db.get "$_1BOTDBPATH" "$_1BOTDBEXT" "$@"
    return $?
}

_1bot.db.set() {
    _1db.set "$_1BOTDBPATH" "$_1BOTDBEXT" "$@"
    return $?
}

_1bot.db.show() {
    _1menuheader "$(_1text "Saved groups for $1")"
    _1db.show "$_1BOTDBPATH" "$_1BOTDBEXT" "$@"
    return $?
}

# @description Find group in received messages
_nh1bot.telegram.findgroup() {
    local _GRP _NAM _LIN
    _1bot.db.show telegram
    if [ $_1BOTTELEGRAM = 0 ]
    then
        _1bot.missing telegram token
        return 1
    fi
    _1verbs "URL: https://api.telegram.org/bot$_1BOTTELEGRAM/getUpdates"
    _1menuheader "$(_1text "New groups")"
    for _LIN in $(curl -s https://api.telegram.org/bot$_1BOTTELEGRAM/getUpdates | tr '{}' '\n\n' | grep "\"type\":\"group\"" | uniq | \
        tr " =" "__" | sed "s/\(.*\)\"id\":\(-[0-9]*\),\"title\":\"\([^\"]*\)\"\(.*\)/\2=\3/" | xargs)
    do
        _GRP=$(echo "$_LIN" | sed "s/\(-[0-9]*\)=\(.*\)/\1/")
        _NAM=$(echo "$_LIN" | sed "s/\(-[0-9]*\)=\(.*\)/\2/")
        grep -q "=$_GRP$" "$_1BOTDBPATH/telegram.$_1BOTDBEXT"
        if [ $? -eq 1 ]
        then
            _1message "$(printf "$(_1text "New group found: %s (name: %s)").\n" "$_GRP" "$_NAM")"
        fi
    done
}

# @description Save a group to send messages
# @arg 1 string Group name
# @arg 2 int Group ID
_nh1bot.telegram.savegroup() {
    if [ $# -eq 2 ]
    then
        _1bot.db.set telegram "$1" "$2"
    else
        _nh1bot.usage
    fi
}

# @description Remove a group
# @arg 1 string Group name
_nh1bot.telegram.delgroup() {
    return _1bot.db.set telegram "$1"
}

# @description Send a message to a telegram group
# @arg 1 string Group name
# @arg 2 string Message to send
# @exitcode 0 Ok
# @exitcode 1 Token not configured
_nh1bot.telegram.say() {
    local _MTO _MSG _GRP
    if [ $_1BOTTELEGRAM = 0 ]
    then
        _1bot.missing telegram token
        return 1
    fi
    if [ $# -eq 2 ]
    then
        _MTO=$(_1bot.db.get telegram "$1")
        if [ $? -eq 0 ]
        then
            _GRP="$1"
            shift
            _MSG="$(1morph urlencode "$*")"
            _1verb "$(printf "$(_1text "Sending %s \"%s\" to %s group via %s")" "$(_1text "message")" "$_MSG" "$_GRP" "telegram")"
            curl --silent -X POST --data-urlencode "chat_id=$_MTO" \
                --data "text=$_MSG" \
                "https://api.telegram.org/bot$_1BOTTELEGRAM/sendMessage?disable_web_page_preview=true&parse_mode=markdown" | \
                grep -q '"ok":true'
            return $?
        fi
    fi
    _nh1bot.usage
}

# @description Send a file to a telegram group
# @arg 1 string Group name
# @arg 2 string Path to file
# @exitcode 0 Ok
# @exitcode 1 Token not configured
_nh1bot.telegram.send() {
    local _MTO _FIL _GRP _RES
    if [ $_1BOTTELEGRAM = 0 ]
    then
        _1bot.missing telegram token
        return 1
    fi
    if [ $# -eq 2 ]
    then
        _MTO=$(_1bot.db.get telegram "$1")
        if [ $? -eq 0 ]
        then
            _GRP="$1"
            _FIL="$2"
            if [ -f "$_FIL" ]
            then
                _1verb "$(printf "$(_1text "Sending %s \"%s\" to %s group via %s")" "$(_1text "file")" "$_FIL" "$_GRP" "telegram")"
                _RES=$(curl --silent -F "chat_id=$_MTO" -F "document=@$_FIL" "https://api.telegram.org/bot$_1BOTTELEGRAM/sendDocument")
                return $?
            else
                _1message error "$(printf "$(_1text "File %s not found")" "$_FIL")"
            fi
        fi
    fi
    _nh1bot.usage
}


# Public functions

1bot() {
    local _SRV
    if [ $# -ge 2 ]
    then
        _SRV=$1
        if [ $_SRV != "telegram" ]
        then
            _nh1bot.usage
            return 1
        fi
        shift
        case "$1" in
            group-list)
                _nh1bot.telegram.findgroup
                ;;
            group-add)
                shift
                _nh1bot.telegram.savegroup "$@"
                ;;
            group-del)
                shift
                _nh1bot.telegram.delgroup "$@"
                ;;                
            say)
                shift
                _nh1bot.telegram.say "$@"
                ;;
            send)
                shift
                _nh1bot.telegram.send "$@"
                ;;
            *)
                _nh1bot.usage
                ;;
        esac
    else
        _nh1bot.usage
    fi
}

