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
  1tint $XC "1roll"
  echo           "    Roll dices with RPG formula: 2d10, 1d4+1..."
  1tint $WC "1dice"
  echo           "    Roll a single dice from N faces (default: 6)"
  1tint $WC "1d4"
  echo         "      Roll one d4"
  1tint $WC "1d6"
  echo         "      Roll one d6"
  1tint $WC "1d8"
  echo         "      Roll one d8"
  1tint $WC "1d10"
  echo          "     Roll one d10"
  1tint $WC "1d12"
  echo          "     Roll one d12"
  1tint $WC "1d20"
  echo          "     Roll one d20"
  1tint $WC "1d100"
  echo           "    Roll one d100"
  1tint $PC "1card"
  echo
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
