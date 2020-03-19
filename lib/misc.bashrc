#!/bin/bash

# Generate partial menu
function _nh1misc.menu {
  echo "___ Miscelania ___"
  _1menuitem X 1ajoin "# Join an array, using first param as delimiter"
	_1menuitem P 1du "to-do"
  _1menuitem X 1pdfopt "Compress a PDF file" gs
  _1menuitem W 1pomo "Run one pomodoro (default is 25min)" seq
  _1menuitem W 1power "Print percentage for battery (notebook)" upower
}

# Destroy all global variables created by this file
function _nh1misc.clean {
  unset -f _nh1misc.menu _nh1misc.clean 1power 1pdfopt 1ajoin 1pomo
}

# Print percentage for battery charge
function 1power {
  if 1check upower
  then
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage
  fi
}

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

# Create a Pomodore in shell
# @param minutes to pomodoro (default 25)
function 1pomo {
  1tint 2 "Pomodoro"
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
  if [ $MINUTES -ge 10 ]
  then
    echo -n ": $MINUTES:00"
  else
    echo -n ": 0$MINUTES:00"
  fi
  UNCLOCK="\b\b\b\b\b\b"
  for MIN in `seq -f "%02g" $((MINUTES-1)) -1 0`
  do
    for SEC in `seq -f "%02g" 59 -1 0`
    do
      sleep 1
      echo -en "$UNCLOCK" "$MIN:$SEC"
    done
  done
  1alarm
  echo -e "$UNCLOCK" "finished"
}
