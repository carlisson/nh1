#!/bin/bash


# GLOBALS
_1VERSION=0.2

_1RC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
_1LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib"

# Menu for NH1
function NH1 {
		PC=5
		XC=3
		WC=2

    echo "NH1 $_1VERSION"
    echo

		1tint $PC "1roll"
		echo
		1tint $PC "1d4"
		echo
		1tint $PC "1d6"
		echo
		1tint $PC "1d8"
		echo
		1tint $PC "1d10"
		echo
		1tint $PC "1d12"
		echo
		1tint $PC "1d20"
		echo
		1tint $PC "1d100"
		echo
		1tint $PC "1card"
		echo
		1tint $PC "1du"
		echo
		1tint $PC "1install"
		echo
		1tint $PC "1ports"
		echo
		1tint $PC "1bashrc"
		echo             "  Modify .bashrc to NH1 starts on bash start"
		1tint $PC "1update"
		echo
		1tint $PC "1yt3"
		echo
		1tint $PC "nh1localnet"
		echo
		1tint $PC "nh1connect"
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
		echo "Power-up for your shell"
		echo " -------------------------------------"
    echo
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
