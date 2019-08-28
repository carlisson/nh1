#!/bin/bash


# GLOBALS
_1RC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
_1VERSION=0.1

# Menu for NH1
function NH1 {
    echo "NH1 $_1VERSION"
    echo

		1tint "1tint"
		echo       "  Write a string in another color"

		echo
		echo -n "   "
		1tint 5 "planning"
		echo -n "   "
		1tint 3 "experimental"
		echo -n "   "
		1tint "working"
		echo
		echo " -------------------------------------"
		echo "Power-up for your shell"
		echo " -------------------------------------"
    echo
}

# Set text color in shell
# @param The color number (optional)
# @param Text to tint
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
