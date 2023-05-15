#!/bin/bash
# @file bot.bashrc
# @brief Bot to send messages

# GLOBALS
_1BOTTELEGRAM=0
_1BOTNTALK=0
_1BOTDESCRIPTION="$(_1text "Bot system to send messages")"
_1BOTDBPATH="$_1UDATA/bots"
_1BOTDBEXT="bt"
_1BOTTYPES=(nextcloud telegram)

# Private functions

# @description Special menu item
_nh1bot.item() {
    _1menuitem W 1bot "$_1BOTDESCRIPTION"
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
  _1customvar NORG_BOT_NEXTCLOUD _1BOTNTALK
}

# @description General information about variables and customizing
_nh1bot.info() {
  _1menuitem W NORG_BOT_TELEGRAM "$(_1text "Token for Telegram bot. Get it from @BotFather")"
  _1menuitem W NORG_BOT_NEXTCLOUD "$(_1text "Login and password for Nextcloud bot. In format server|login|password")"
}

# @description Creates paths and copy initial files
_nh1bot.init() {
  mkdir -p "$_1BOTDBPATH"
  touch "$_1BOTDBPATH/telegram.$_1BOTDBEXT"
  touch "$_1BOTDBPATH/nextcloud.$_1BOTDBEXT"
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1bot.usage() {
    printf "$(_1text "Usage: %s %s [%s] [%s]")\n" "1bot" "$(_1text "type")" "$(_1text "Command")" "$(_1text "Other options")"
    printf "  - telegram $(_1text "works as a Telegram bot")\n"
    printf "  - nextcloud $(_1text "works as a Nextcloud talk bot")\n"
    echo
    echo "$(_1text "Commands"):"
    printf "  - get [%s] %s\n" "$(_1text "Path to remote file")" "$(_1text "Get a file from server")"
    printf "  - group-list %s\n" "$(_1text "list new groups for telegram bot")"
    printf "  - group-add [%s] [%s] %s\n" "$(_1text "Group name")" "$(_1text "Group ID")" "$(_1text "Save a group")"
    printf "  - group-del [%s] %s\n" "$(_1text "Group name")" "$(_1text "Delete a group")"
    printf "  - put [%s] [%s] %s\n" "$(_1text "Remote directory")" "$(_1text "Local file")" "$(_1text "Puts a file")"
    printf "  - say [%s] [%s] %s\n" "$(_1text "Group name")" "$(_1text "message")" "$(_1text "Send a message")"
    printf "  - send [%s] [%s] %s\n" "$(_1text "Group name")" "$(_1text "path to file")" "$(_1text "Send a file")"
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
    _1verb "URL: https://api.telegram.org/bot$_1BOTTELEGRAM/getUpdates"
    _1menuheader "$(_1text "New groups")"
    for _LIN in $(curl -s https://api.telegram.org/bot$_1BOTTELEGRAM/getUpdates | tr '{}' '\n\n' | grep "\"type\":\"group\"" | \
        sed 's/\"type\":\"group\"\(.*\)//' | uniq | \
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
# @arg $1 string Bot type
# @arg $2 string Group name
# @arg $3 int Group ID
_nh1bot.savegroup() {
    if [ $# -eq 3 ]
    then
        _1bot.db.set "$1" "$2" "$3"
    else
        _nh1bot.usage
    fi
}

# @description Remove a group
# @arg $1 string Bot type
# @arg $2 string Group name
_nh1bot.delgroup() {
    return _1bot.db.set "$1" "$2"
}

# @description Send a message to a telegram group
# @arg 1 string Group name
# @arg 2 string Message to send
# @exitcode 0 Ok
# @exitcode 1 Token not configured
_nh1bot.telegram.say() {
    echo "[$1] [$2]"
    local _MTO _MSG _GRP
    if [ $_1BOTTELEGRAM = 0 ]
    then
        _1bot.missing telegram token
        return 1
    fi
    if [ $# -gt 1 ]
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

# @description Send a message to a Nextcloud Talk room
# @arg 1 string Group name
# @arg 2 string Message to send
# @exitcode 0 Ok
# @exitcode 1 Credentials not configured
_nh1bot.nextcloud.say() {
    local _MTO _MSG _GRP _USR _PASS _SRV
    if [ $_1BOTNTALK = 0 ]
    then
        _1bot.missing nextcloud credentials
        return 1
    else
        _SRV=$(echo $_1BOTNTALK | cut -d\| -f 1)
        _USR=$(echo $_1BOTNTALK | cut -d\| -f 2)
        _PASS=$(echo $_1BOTNTALK | cut -d\| -f 3)
    fi
    if [ $# -gt 1 ]
    then
        _MTO=$(_1bot.db.get nextcloud "$1")
        if [ $? -eq 0 ]
        then
            _GRP="$1"
            shift
            _MSG="$*"
            _1verb "$(printf "$(_1text "Sending %s \"%s\" to %s group via %s")" "$(_1text "message")" "$_MSG" "$_GRP" "nextcloud talk")"

            curl --silent -H "Content-Type: application/json" -H "Accept: application/json" -H "OCS-APIRequest: true" -q -u \
                "$_USR:$_PASS" -d "{\"token\":\"$_MTO\",\"message\":\"$_MSG\"}" "$_SRV/ocs/v2.php/apps/spreed/api/v1/chat/$_MTO" >2&
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

# @description Get a file from a Nextcloud account
# @arg 1 string Path to remote file
# @exitcode 0 Ok
# @exitcode 1 Token not configured
_nh1bot.nextcloud.get() {
    local _RTO _FIL _USR _PASS _SRV
    if [ $_1BOTNTALK = 0 ]
    then
        _1bot.missing nextcloud credentials
        return 1
    else
        _SRV=$(echo $_1BOTNTALK | cut -d\| -f 1)
        _USR=$(echo $_1BOTNTALK | cut -d\| -f 2)
        _PASS=$(echo $_1BOTNTALK | cut -d\| -f 3)
    fi
    if [ $# -ge 1 ]
    then
        _RTO="$1"
        shift
        _FIL="$(echo "$_RTO" | sed 's/\(.*\)\/\([^\/]*\)/\2/')"
        _1verb "$(printf "$(_1text "Geting %s \"%s\" from %s via %s")" "$(_1text "file")" "$_FIL" "$_RTO" "nextcloud files")"

        curl --silent -u $_USR:$_PASS -o "$_FIL" "$_SRV/remote.php/dav/files/$_USR/$_RTO/" >2&
        return $?
    fi
    _nh1bot.usage
}

# @description Puts a file into a Nextcloud account
# @arg 1 string Destination path
# @arg 2 string Path to file
# @exitcode 0 Ok
# @exitcode 1 Token not configured
_nh1bot.nextcloud.put() {
    local _RTO _FIL _USR _PASS _SRV
    if [ $_1BOTNTALK = 0 ]
    then
        _1bot.missing nextcloud credentials
        return 1
    else
        _SRV=$(echo $_1BOTNTALK | cut -d\| -f 1)
        _USR=$(echo $_1BOTNTALK | cut -d\| -f 2)
        _PASS=$(echo $_1BOTNTALK | cut -d\| -f 3)
    fi
    if [ $# -gt 1 ]
    then
        _RTO="$1"
        shift
        _FIL="$*"
        _1verb "$(printf "$(_1text "Putting %s \"%s\" into %s directory on %s")" "$(_1text "file")" "$_FIL" "$_RTO" "nextcloud files")"

        curl --silent -u $_USR:$_PASS -T "$_FIL" "$_SRV/remote.php/dav/files/$_USR/$_RTO/" >2&
        return $?
    fi
    _nh1bot.usage
}

# Public functions

1bot() {
    _1before
    local _SRV _AUX
    if [ $# -ge 2 ]
    then
        _AUX="$1"
        case "$2" in
            get)
                shift 2
                case "$_AUX" in
                    nextcloud)
                        _nh1bot.nextcloud.get "$@"
                        return 0
                        ;;
                esac
                ;;
            group-list)
                shift 2
                case "$_AUX" in
                    telegram)
                        _nh1bot.telegram.findgroup
                        return 0
                        ;;
                    *)
                        _1bot.db.show "$_AUX"
                        return 0
                        ;;
                esac
                ;;
            group-add)
                shift 2
                _nh1bot.savegroup "$_AUX" "$@"
                return 0
                ;;
            group-del)
                shift 2
                _nh1bot.delgroup "$_AUX" "$@"
                return 0
                ;;       
            put)
                shift 2
                case "$_AUX" in
                    nextcloud)
                        _nh1bot.nextcloud.put "$@"
                        return 0
                        ;;
                esac
                ;;
            say)
                shift 2
                case "$_AUX" in
                    telegram)
                        _nh1bot.telegram.say "$@"
                        return 0
                        ;;
                    nextcloud)
                        _nh1bot.nextcloud.say "$@"
                        return 0
                        ;;
                esac
                ;;
            send)
                shift 2
                case "$_AUX" in
                    telegram)
                        _nh1bot.telegram.send "$@"
                        return 0
                        ;;
                esac
                ;;
            *)
                _nh1bot.usage
                return 2
                ;;
        esac
    fi
    _nh1bot.usage
    return 1
}

