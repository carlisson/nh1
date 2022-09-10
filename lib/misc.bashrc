#!/bin/bash

# Generate partial menu
function _nh1misc.menu {
  echo "___ Miscelania ___"
  _1menuitem X 1ajoin "Join an array, using first param as delimiter"
  _1menuitem W 1color "Generate a random hexadecimal color"
  _1menuitem W 1du "Disk usage" du
  _1menuitem X 1escape "Rename a file or dir, excluding special chars"
  _1menuitem W 1pass "Generate a secure password" openssl
  _1menuitem X 1pdfopt "Compress a PDF file" gs
  _1menuitem W 1pomo "Run one pomodoro (default is 25min)" seq
  _1menuitem W 1power "Print percentage for battery (notebook)" upower
  _1menuitem W 1rr30 "Counter 30-30-30 to router reset" seq
  _1menuitem W 1timer "Countdown timer." seq
}

# Destroy all global variables created by this file
function _nh1misc.clean {
  unset 1color 1du 1pass
  unset -f _nh1misc.menu _nh1misc.clean 1power 1pdfopt 1ajoin 1pomo 1escape
  unset -f 1timer 1rr30
}

# Print percentage for battery charge
function 1power {
  if 1check upower
  then
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage
  fi
}

alias 1du="du -h -d 1"
alias 1pass="openssl rand -base64 16 | rev | cut -c 3-13"
alias 1color="openssl rand -hex 3"

# Compress PDF file
# @param PDF input file
# @param PDF output file (optional)
function 1pdfopt {
  if 1check gs
  then
    if [ $# -gt 0 ]
    then
    	local INF="$1"
      local OUF
      if [ $# -eq 2 ]
      then
        OUF="$2"
      else
        OUF=`basename "$INF" .pdf`-opt.pdf
      fi
    	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$OUF $INF
    else
      echo "Use: 1pdfopt <PDF-input> <PDF-output optional>"
    fi
  fi
}

# Join an array, using first param as delimiter
# @param delimiter, character
# @param other values to join
function 1ajoin {
  local IFS="$1"
  shift
  echo "$*"
}

# Countdown timer
# @param color for timer (0 to 7)
# @param title for timer
# @param seconds
# @param minutes
# @param hours to countdown
function 1timer {
  local HOURS MINUTES SECONDS TITLE COLOR CLOCK IH IM IS UNCLOCK IU
  if [ $# -gt 4 ]
  then
    HOURS=$5
  else
    HOURS=0
  fi
  if [ $# -gt 3 ]
  then
    MINUTES=$4
  else
    MINUTES=0
  fi
  if [ $# -gt 2 ]
  then
    COLOR=$1
    TITLE=$2
    SECONDS=$3
    UNCLOCK=""

    1tint $COLOR "$TITLE"

    for IH in $(seq -f "%02g" $HOURS -1 0)
    do
      for IM in $(seq -f "%02g" $MINUTES -1 0)
      do
        for IS in $(seq -f "%02g" $SECONDS -1 0)
        do
          CLOCK="$IH:$IM:$IS"
          echo -en "$UNCLOCK" "$CLOCK"
          UNCLOCK=""
          for IU in $(seq 0 ${#CLOCK})
          do
            UNCLOCK="\b$UNCLOCK"
          done
          sleep 1
        done
        SECONDS=59
        IM=$((IM-1))        
      done
      MINUTES=59
      IH=$((IH-1))        
    done
    echo -e "$UNCLOCK" "finished"
  else
    echo "Usage:"
    echo "  1timer <COLOR> <TITLE> <SECONDS> <MINUTES> <HOURS>"
  fi
}

# Create a Pomodore in shell
# @param minutes to pomodoro (default 25)
function 1pomo {
  local MINUTES
  
  MINUTES=25
  if [ $# -eq 1 ]
  then
    if [ $1 -gt 99 ]
    then
      MINUTES=99
    elif [ $1 -gt 0 ]
    then
      MINUTES=$1
    fi
  fi
  1timer 2 "Pomodoro" 0 $MINUTES
  1alarm
}

# Timer to help to reset a router, using the 30-30-30 method
function 1rr30 {
  echo
  1tint 3 "30-30-30 method for router reseting"
  echo " - your router will lost all configuration"
  echo " 1. Turn on the router."
  echo " 2. Press and hold reset button. Wait 30 seconds."
  echo " 3. Turn off the router. Wait 30 seconds."
  echo " 4. Turn on the router. Wait 30 seconds."
  echo " 5. Release the button"
  1tint 3 "Press ENTER when you are ready."
  read
  1timer 2 "Router on" 30
  1alarm
  1timer 4 "Router off" 30
  1alarm
  1timer 2 "Router on" 30
  1alarm
  echo
  echo "Your router must be restarted with factory settings!"
}

# Rename a file or directory, removing special chars
# @param file
function 1escape {
  local EDIR EFIL EFN
  for EPAR in "$@"
  do
    EDIR=$(dirname "$EPAR")
    EFIL=$(basename "$EPAR")
    pushd $EDIR > /dev/null
    EFN="$(sed 's/[^0-9A-Za-z_.]/_/g' <<< "$EFIL")"
    if [ "$EFIL" != "$EFN" ]
    then
      mv "$EFIL" "$(sed 's/[^0-9A-Za-z_.]/_/g' <<< "$EFIL")"
    fi
    popd > /dev/null
  done
}

