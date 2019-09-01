#!/bin/bash

# Generate partial menu
function _nh1misc.menu {
  echo "___ Miscelania ___"
	_1menuitem P 1du "to-do"
  _1menuitem X 1pdfopt "Compress a PDF file" gs
  _1menuitem W 1power "Print percentage for battery (notebook)" upower
}

# Destroy all global variables created by this file
function _nh1misc.clean {
  unset -f _nh1misc.menu _nh1misc.clean 1power 1pdfopt
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
    	INF="$1"
      if [ $# -eq 2 ]
      then
        OUF="$2"
      else
        OUF=`basename "$INF" .pdf`-opt.pdf
      fi
    	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$OUF $INF
      unset INF OUF
    else
      echo "Use: 1pdfopt <PDF-input> <PDF-output optional>"
    fi
  fi
}
