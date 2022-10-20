#!/bin/bash
# @file rpg.bashrc
# @brief RPG tools

_1RPGDRAW="$_1UDATA/drawlists"

# @description Generate partial menu (for RPG functions)
_nh1rpg.menu() {
  echo "___ $(_1text RPG) ___"
  _1menuitem W 1dice "$(_1text "Roll a single dice from N faces (default: 6)")"
  _1menuitem W 1roll "$(_1text "Roll dices with RPG formula: 2d10, 1d4+1...")"
  _1menuitem W 1d4 "$(_1text "Roll one d4 dice")"
  _1menuitem W 1d6 "$(_1text "Roll one d6 dice")"
  _1menuitem W 1d8 "$(_1text "Roll one d8 dice")"
  _1menuitem W 1d10 "$(_1text "Roll one d10 dice")"
  _1menuitem W 1d12 "$(_1text "Roll one d12 dice")"
  _1menuitem W 1d20 "$(_1text "Roll one d20 dice")"
  _1menuitem W 1d100 "$(_1text "Roll one d100 dice")"
  _1menuitem W 1card "$(_1text "Sort a random playing card")"
  _1menuitem W 1draw "$(_1text "Draw an item from a list")"
  _1menuitem W 1drawlist "$(_1text "List groups to draw-functions")"
  _1menuitem W 1drawadd "$(_1text "Add a new group to draw-functions")"
  _1menuitem W 1drawdel "$(_1text "Delete a group from draw-functions")"
}

# @description Destroy all global variables created by this file
_nh1rpg.clean() {
  unset _1RPGDRAW
  unset -f 1d4 1d6 1d8 1d10 1d12 1d20 1d100
  unset -f _nh1rpg.menu _nh1rpg.clean 1dice 1roll 1card
  unset -f 1draw 1drawlist 1drawadd 1drawdel _nh1rpg.init
  unset -f _nh1rpg.complete _nh1rpg.complete.draw
}

# @description Auto-completion
_nh1rpg.complete() {
    complete -F _nh1rpg.complete.draw 1draw
    complete -F _nh1rpg.complete.draw 1drawlist
}

# @description Auto-completion for 1draw
_nh1rpg.complete.draw() {
  COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
        COMPREPLY=($(_1list $_1RPGDRAW "list"))
    fi
}

# @description Initial commands
_nh1rpg.init() {
	mkdir -p "$_1RPGDRAW"
}

# @description Apply custom vars from config file
_nh1rpg.customvars() {
  if [[ $NORG_DRAW_LISTS_DIR ]]
    then
        _1RPGDRAW="$NORG_DRAW_LISTS_DIR"
    fi
}

# @description General information about variables and customizing
_nh1rpg.info() {
  _1menuitem W NORG_DRAW_LISTS_DIR "$(_1text "Path for draw-lists (RPG).")"
}

# Alias like

# @description Rolls a 4-sided dice
# @stdout Result for rolling
# @see 1dice
1d4()   { 1dice 4 ; }

# @description Rolls a 6-sided dice
# @stdout Result for rolling
# @see 1dice
1d6()   { 1dice ; }

# @description Rolls an 8-sided dice
# @stdout Result for rolling
# @see 1dice
1d8()   { 1dice 8 ; }

# @description Rolls a 10-sided dice
# @stdout Result for rolling
# @see 1dice
1d10()  { 1dice 10 ; }

# @description Rolls a 12-sided dice
# @stdout Result for rolling
# @see 1dice
1d12()  { 1dice 12 ; }

# @description Rolls a 20-sided dice
# @stdout Result for rolling
# @see 1dice
1d20()  { 1dice 20 ; }

# @description Rolls a 100-sided dice
# @stdout Result for rolling
# @see 1dice
1d100() { 1dice 100 ; }

# @description Generate a random number, like from a dice from N sides
# @arg $1 int number of sides of the dice (default 6)
# @stdout Result for rolling
# @see 1roll
1dice() {
	local SIDES=6
	if [ $# -eq 1 ]
	then
		SIDES=$1
	fi
	shuf -i 1-$SIDES -n 1
}

# @description Roll dices from a RPG formula
# @arg $1 string Formula like XdY+Z or XdY-Z
# @see 1dice
1roll() {
  local ROLLNUM ROLLSID ROLLADD ROLLDET ROLLTOT
	if [ $(echo $1 | grep d) ]
	then
		ROLLNUM=$(echo $1 | sed 's/d.*//')
		if [ $(echo $1 | egrep '[+-]') ]
		then
			ROLLSID=$(echo $1 | sed 's/.*d\(.*\)[+-].*/\1/g')
			ROLLADD=$(echo $1 | sed 's/.*\([+-]\)/\1/g')
		else
			ROLLSID=$(echo $1 | sed 's/.*d//g')
			ROLLADD=''
		fi
		ROLLDET=""
		ROLLTOT=0
		for i in $(seq 1 $ROLLNUM)
		do
			AUX=$(1dice $ROLLSID)
			if [ $ROLLTOT -eq 0 ]
			then
				ROLLDET="$AUX"
			else
				ROLLDET="$ROLLDET $AUX"
			fi
			ROLLTOT=$(($ROLLTOT+$AUX))
		done
    if [ -n "$ROLLADD" ]
    then
      ROLLTOT=$(($ROLLTOT $ROLLADD))
      ROLLADD=" $ROLLADD"
    fi
		echo "$ROLLTOT ($ROLLDET$ROLLADD)"
	else
		echo "$(_1text "Params"): xdy+z. $(_1text "Examples"): 3d6, 5d8-4, 1d4+1"
	fi
}

# @description Random playing card
1card() {
	local FSUIT FNUMB SUIT NUMB
	if [ $(shuf -i 1-27 -n 1) -eq 1 ]
	then
	  _1text "Joker"
	  echo
	else
		SUIT=$(tr -dc 'CDHS' < /dev/urandom | head -c 1)
		NUMB=$(tr -dc 'A23456789XJQK' < /dev/urandom | head -c 1)
		case $NUMB in
			A) FNUMB=$(_1text "Ace") ;;
			J) FNUMB=$(_1text "Jack") ;;
			Q) FNUMB=$(_1text "Queen") ;;
			K) FNUMB=$(_1text "King") ;;
			X) FNUMB="10" ;;
			*) FNUMB="$NUMB" ;;
		esac
		case $SUIT in
			C) FSUIT=$(_1text "Clubs") ;;
			D) FSUIT=$(_1text "Diamonds") ;;
			H) FSUIT=$(_1text "Hearts") ;;
			S) FSUIT=$(_1text "Spades") ;;
		esac
		printf "$(_1text "%s of %s")\n" $FNUMB $FSUIT
	fi
}

# @description List all groups/lists from where to draw elements
# @arg $1 string group name (optional)
1drawlist() {
    local _dlist _slist
    
    _dlist=($(_1list "$_1RPGDRAW" "list"))
    _slist="${_dlist[@]}"
    
	if [ $# -eq 1 ]
	then
		if 1check less
		then
			less -N "$_1RPGDRAW/$1.list"
		else
			cat -n "$_1RPGDRAW/$1.list"
		fi
	else
    	if [ ${#_dlist[@]} -eq 0 ]
    	then
	        _1text "No group found."
			echo
		else
 	    	printf "$(_1text "Groups: %s.")\n" "$_slist"
    	fi
	fi
}

# @description Add a group list from a text file, with one option per line
# @arg $1 string Input text file
1drawadd() {
    local ni no
    case $# in
        1)
            ni="$1"
            no="$(basename $1 .txt).list"
            ;;
        2)
            ni="$1"
            no="$2"
            if [ "${no: -4}" = ".txt" ]
			then
				no="$(basename $1 .txt).list"
            elif [ "${no: -5}" != ".list" ]
            then
                no="$no.list"
			fi
            ;;
        *)
            printf "$(_1text "Usage: %s.")\n" "1drawadd <text-file> (<group-name>)"
            return
            ;;
    esac
    cp "$ni" "$_1RPGDRAW/$no"
}

# @description Withdraw one item from a given group
# @arg $1 string Group name
1draw() {
	local _group _list
	_group="$1"
	_list="$_1RPGDRAW/$_group.list"
	if [ $# -eq 0 ]
	then
		printf "$(_1text "Usage: %s.")\n" "1draw <group-name>"
	else
		if [ -f "$_list" ]
		then
			cat "$_list" | shuf | head -1
		else
			printf "$(_1text "File not found for group %s.")\n" "$_group"
		fi
	fi
}

# @description Delete a group list
# @arg $1 string Group name
1drawdel() {
    if [ -f "$_1RPGDRAW/$1.list" ]
    then
        rm "$_1RPGDRAW/$1.list"
    else
        printf "$(_1text "Group %s not found.")\n" $1
    fi
}