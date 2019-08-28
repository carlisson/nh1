#!/bin/bash

shopt -s expand_aliases

# GLOBALS
_1VERSION=0.5

_1RC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
_1LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib"

# ALIASES
alias 1d4="1dice 4"
alias 1d6="1dice"
alias 1d8="1dice 8"
alias 1d10="1dice 10"
alias 1d12="1dice 12"
alias 1d20="1dice 20"
alias 1d100="1dice 100"

# Menu for NH1
function NH1 {
	$("1$1")

	if [ $# -eq 1 ]
	then
		$("1$1")
	else
		PC=5
		XC=3
		WC=2

		echo " -------------------------------------"
		echo -n "            "
    1tint "NH1 $_1VERSION"
		echo
		echo " -------------------------------------"
    echo

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
		1tint $PC "1du"
		echo
		1tint $PC "1install"
		echo
		1tint $PC "1ports"
		echo
		1tint $WC "1bashrc"
		echo             "  Modify .bashrc to NH1 starts on bash start"
		1tint $XC "1update"
		echo             "  Update your NH1, using git"
		1tint $WC "1version"
		echo              " List NH1 version and latest changes/updates"
		1tint $PC "1yt3"
		echo
		1tint $PC "nh1localnet"
		echo
		1tint $PC "nh1connect"
		echo
		1tint $PC "nh1interactive"
		echo

		1tint $WC "1tint"
		echo           "    Write a string in another color"

		echo
		echo -n "   "
		1tint $PC "planning"
		echo -n "   "
		1tint $XC "experimental"
		echo -n "   "
		1tint $WC "working"
		echo
		echo " -------------------------------------"
		echo "        Power-up for your shell"
		echo " -------------------------------------"
    echo
	fi
}

# Set text color in shell
# @param The color number (optional)
# @param Text to 1tint
function 1tint {
	if [ $# -eq 0 ]
	then
		echo "You need to put a string and a color number (optional)"
		1tint 0 "0 black"; echo
		1tint 1 "1 red"; echo
		1tint 2 "2 green"; echo
		1tint 3 "3 yellow"; echo
		1tint 4 "4 blue"; echo
		1tint 5 "5 magenta"; echo
		1tint 6 "6 cyan"; echo
		1tint 7 "7 white"; echo
		return 1
	fi
	if [ $# -eq 1 ]
	then
		COLOR=$_1COLOR
		MSG=$1
	else
		COLOR=$1
		MSG=$2
	fi
	tput setaf $COLOR
	echo -n $MSG
	tput sgr0
	return 0
}

alias 1help=NH1

# Check if a program exists. Finish NH1 if it do not exists.
# @param Program to check
function 1check {
	if [ -z "$(whereis -u "$1")" ]
	then
		echo "Program $1 does not exist or it is unavailable for $USER."
		return 1
	fi
	return 0
}

# Modify ~/.bashrc to init NH1 on bash start
function 1bashrc {
    S1="source $_1RC"
    if grep "$S1" ~/.bashrc > /dev/null
    then
      echo "NH1 is already installed in your profile. Run NH1 to see all commands available."
    else
			echo -n "Installing NH1 in $HOME/.bashrc... "
    	echo "$S1" >> ~/.bashrc
			echo "Done!"
    fi
}

# Get git credentials to update NH1
function 1update {
	if 1check git
	then
		pushd "$_1LIB/.." || return 1
		git pull
		popd || return 2
		# shellcheck source=/dev/null
		source "$_1RC"
		1version
		echo
	fi
}


# List version software and list latest entries from changelog
function 1version {
	echo "NH1 $_1VERSION"
	echo
	tail "$_1LIB/changelog.txt"
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
			ROLLADD='+0'
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
		ROLLTOT=$(($ROLLTOT $ROLLADD))
		echo "$ROLLTOT ($ROLLDET $ROLLADD)"
	else
		echo "Params: xdy+z. Examples: 3d6, 5d8-4, 1d4+1"
	fi
}


#MAIN

# Try to execute a `return` statement,
# but do it in a sub-shell and catch the results.
# If this script isn't sourced, that will raise an error.
if return >/dev/null 2>&1
then
	S1="source $_1RC"
	if ! grep "$S1" ~/.bashrc > /dev/null
	then
    NH1
	fi
else
		echo "You need run:"
		echo "source $_1RC"
fi
