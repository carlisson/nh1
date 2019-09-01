#!/bin/bash

# ALIASES
alias 1d4="1dice 4"
alias 1d6="1dice"
alias 1d8="1dice 8"
alias 1d10="1dice 10"
alias 1d12="1dice 12"
alias 1d20="1dice 20"
alias 1d100="1dice 100"

# Generate partial menu (for RPG functions)
function _nh1rpg.menu {
  echo "___ RPG ___"
  _1menuitem W 1dice "Roll a single dice from N faces (default: 6)"
  _1menuitem W 1roll "Roll dices with RPG formula: 2d10, 1d4+1..."
  _1menuitem W 1d4 "Roll one d4 dice"
  _1menuitem W 1d6 "Roll one d6 dice"
  _1menuitem W 1d8 "Roll one d8 dice"
  _1menuitem W 1d10 "Roll one d10 dice"
  _1menuitem W 1d12 "Roll one d12 dice"
  _1menuitem W 1d20 "Roll one d20 dice"
  _1menuitem W 1d100 "Roll one d100 dice"
  _1menuitem W 1card "Sort a random playing card"
}

# Destroy all global variables created by this file
function _nh1rpg.clean {
  unalias 1d4 1d6 1d8 1d10 1d12 1d20 1d100
  unset -f _nh1rpg.menu _nh1rpg.clean 1dice 1roll 1card
}

# Generate a random number, like from a dice from N sides
# @param number of sides of the dice (default 6)
function 1dice {
	SIDES=6
	if [ $# -eq 1 ]
	then
		SIDES=$1
	fi
	shuf -i 1-$SIDES -n 1
  unset SIDES
}

# Roll dices from a RPG formula
# @param Formula like XdY+Z or XdY-Z
function 1roll {
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
    unset ROLLNUM ROLLSID ROLLADD ROLLDET ROLLTOT
	else
		echo "Params: xdy+z. Examples: 3d6, 5d8-4, 1d4+1"
	fi
}

# Random playing card
function 1card {
	SUIT=`tr -dc 'CDHS' < /dev/urandom | \
    head -c 1 | sed 's/C/Clubs/' | \
    sed 's/D/Diamonds/' | sed 's/H/Hearts/' | sed 's/S/Spades/'`
	NUMB=`tr -dc 'A23456789XJQK' < /dev/urandom | head -c 1 | \
  sed 's/X/10/' | sed 's/A/Ace/' | sed 's/J/Jack/' | \
  sed 's/Q/Queen/' | sed 's/K/King/'`
	echo $NUMB of $SUIT
  unset SUIT NUMB
}
