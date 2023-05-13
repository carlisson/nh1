#!/bin/bash

# Template to write a shellscript based in NH1

# Saves dir from where app is called
CURDIR="$(pwd)"

# Change to project directory. If exec is a link, resolve it!
if [ -L "${BASH_SOURCE[0]}" ]
then
    cd "$(dirname "$(readlink "${BASH_SOURCE[0]}")")"
else
    cd "$(dirname "${BASH_SOURCE[0]}")"
fi

# Get the version from project changelog. Rename this var if you like
# Every line in changelog is like this (incrementing version number):
# 0.1  2023-05-13: What's new in this version
MY2_VERSION="$(tail -n 1 "CHANGELOG" | cut -d\  -f 1)"

# If you use a config file, define the file name and extension here.
MY2_CONF="config.my2"

# Local verbose mode
VERBOSEMODE="N"

# URL to download NH1, if this script run without NH1 installed
NH1PACK="https://codeberg.org/attachments/0da5708e-3c0d-4f6c-a5b5-75aa8641e467" # 1.4.3

# Simple UI
yes_or_no() {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) return  1 ;;
        esac
    done
}

# This will check if NH1 is installed. If not, it ask user for permission
# to install it.
if $(grep -q nh1 ~/.bashrc)
then
    $(grep nh1 "$HOME/.bashrc")
else
    if [ -d "nh1/" ]
    then
        source "nh1/nh1"
    else
        if yes_or_no "NH1 not found. Do you want to download it now?"
        then
            # NH1 v1.4
            if [ -f /usr/bin/wget ]
            then
                wget "$NH1PACK" -O nh1.tgz
            elif [ -f /usr/bin/curl ]
            then
                curl -o nh1.tgz -OL "$NH1PACK"
            else
                echo "2hot needs wget or curl to install nh1"
                exit 1
            fi
            tar -zxf nh1.tgz
            rm nh1.tgz
            source "nh1/nh1"
        else
            echo "You can get it with:"
            echo "  git clone https://codeberg.org/bardo/nh1"
            exit 0
        fi
    fi
fi

# @description Prints if verbose mode is on
# @arg string $1 Message to print
_2verbs() {
	if [ "$VERBOSEMODE" = "Y" ]
	then
		echo "${FUNCNAME[1]}|${FUNCNAME[2]}: $*" >&2
	fi
}

# If your program will read a config file in Walls syntax,
# adapt the follow lines. If not, you can delete it and
# write your own program here.

if ! [[ "$1" =~ ^/ ]]
then
    MY2_CONF="$CURDIR/$1"
fi

# First, you read the config and set variables, doing what you need
if [ -f "$MY2_CONF" ]
then

    # Secure (without change IFS) looping in a file using 1line
    for lnum in $(seq $(1line "$MY2_CONF"))
    do
        line="$(1line "$MY2_CONF" $lnum)"

        # A wall line is like this:
        # COMMAND|ARGUMENT 1|ARGUMENT 2|ARGUMENT 3|ARGUMENT 4
        # COM saves the command, AR[1-4] the arguments
        line=$(echo $line | tr '^' 'n')
        COM="$(echo "$line" | cut -d\| -f 1)"
        AR1="$(echo "$line" | cut -d\| -f 2)"
        AR2="$(echo "$line" | cut -d\| -f 3)"
        AR3="$(echo "$line" | cut -d\| -f 4)"
        AR4="$(echo "$line" | cut -d\| -f 5)"
        
        # If command is not empty and not starts with "#" (comment)...
        if [ ! -z "$COM" ] && ! [[ "$COM" =~ ^# ]]
        then
            case "$COM" in
                # Write a line for each possible command.
                # Creates functions like "mynh2.something"
                #   to organize complex algorithms.
                # If you have a TITLE command with one argument:
#               TITLE)
#                   TITLE="$AR1"
#                   ;;
                *)
                    _1message info "Option $COM not supported yet"
                    ;;
            esac
        fi
    done
else
    _1message error "No config file $MY2_CONF found"
    exit 1
fi

# Finalization goes here!

exit 0
