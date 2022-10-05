#!/bin/bash

_1MISCLOCAL="$_1UDATA/misc"

# Generate partial menu
function _nh1misc.menu {
  echo "___ Miscelania ___"
  _1menuitem X 1ajoin "Join an array, using first param as delimiter"
  _1menuitem X 1booklet "Generate a seq for booklet, for given page number"
  _1menuitem W 1color "Generate a random hexadecimal color" openssl
  _1menuitem W 1du "Disk usage" du
  _1menuitem X 1escape "Rename a file or dir, excluding special chars"
  _1menuitem W 1pass "Generate a secure password" openssl
  _1menuitem X 1pdfbkl "Make a booklet form a PDF file" pdfjam
  _1menuitem X 1pdfopt "Compress a PDF file" gs
  _1menuitem W 1pomo "Run one pomodoro (default is 25min)" seq
  _1menuitem W 1power "Print percentage for battery (notebook)" upower
  _1menuitem W 1rr30 "Counter 30-30-30 to router reset" seq
  _1menuitem X 1spchar "Returns a random special character"
  _1menuitem W 1timer "Countdown timer." seq
  _1menuitem X 1tip "Shows a random tip" shuf
}

# Destroy all global variables created by this file
function _nh1misc.clean {
  unset -f 1color 1du 1pass 1escape 1timer 1rr30 1tip 1spchar
  unset -f _nh1misc.menu _nh1misc.clean 1power 1pdfopt 1ajoin 1pomo
  unset -f 1booklet 1pdfbkl _nh1misc.complete _nh1misc.complete.pdfbkl
}

function _nh1misc.complete {
  complete -F _nh1misc.complete.from_pdf 1pdfbkl
  complete -F _nh1misc.complete.from_pdf 1pdfopt
}

function _nh1misc.complete.from_pdf { _1compl 'pdf' 0 0 0 0 ; }

# Print percentage for battery charge
function 1power {
  if 1check upower
  then
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage
  fi
}

# Alias like
function 1du    { du -h -d 1 ; }
function 1pass  { openssl rand -base64 16 | rev | cut -c 3-13 ; }
function 1color { openssl rand -hex 3 ; }

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

# Shows a random tip to the user
# @param Group of tip ("list" to list all groups)
function 1tip {
    local _TFIL
	if [ $# -eq 0 ]
	then
		cat $_1MISCLOCAL/*.tips | shuf | head -1
	else
		if [ "$1" = "list" ]
		then
			echo -n "Tip groups: "
			for _TFIL in $(ls $_1MISCLOCAL/*.tips)
			do
                1tint 2 $(basename "$_TFIL" ".tips")
                echo -n " "
            done
            echo
        else
            _TFIL=$_1MISCLOCAL/$1.tips
            if [ -f "$_TFIL" ]
            then
                shuf "$_TFIL" | head -1
            else
                echo "No tips group $1 found."
                return 1
            fi
        fi
	fi
	return 0
}

# Returns a random special character
function 1spchar {
  case $(1roll 1d40 | cut -d\  -f 1) in
		1)  echo -n "\"" ;;
		2)  echo -n "'" ;;
		3)  echo -n "!" ;;
		4)  echo -n "¹" ;;
		5)  echo -n "@" ;;
		6)  echo -n "²" ;;
		7)  echo -n "#" ;;
		8)  echo -n "³" ;;
		9)  echo -n "$" ;;
		10) echo -n "£" ;;
		11) echo -n "%" ;;
		12) echo -n "¢" ;;
		13) echo -n "¬" ;;
		14) echo -n "&" ;;
		15) echo -n "*" ;;
		16) echo -n "(" ;;
		17) echo -n ")" ;;
		18) echo -n "-" ;;
		19) echo -n "_" ;;
		20) echo -n "=" ;;
		21) echo -n "+" ;;
		22) echo -n "[" ;;
		23) echo -n "{" ;;
		24) echo -n "ª" ;;
		25) echo -n "~" ;;
		26) echo -n "^" ;;
		27) echo -n "]" ;;
		28) echo -n "}" ;;
		29) echo -n "º" ;;
		30) echo -n "\\" ;;
		31) echo -n "|" ;;
		32) echo -n "<" ;;
		33) echo -n "," ;;
		34) echo -n "." ;;
		35) echo -n ">" ;;
		36) echo -n ";" ;;
		37) echo -n ":" ;;
		38) echo -n "/" ;;
		39) echo -n "?" ;;
		40) echo -n "°" ;;
  esac
}


# Generates a seq of pages to make booklet (4 pages i 2-sides paper)
# @param Number of pages
# @param Number of the "blank" page. Default: last
# @param Mode single or double. Default: single. Any-arg: double.
function 1booklet {
  local _PAG _MIN _MAJ _TOT _BLA _I _MID _REM _OUT _DOB
  _PAG=$1
  if [ $# -ge 2 ]
  then
    _BLA=$2
  else
    _BLA=$1
  fi
  if [ $# -eq 3 ]
  then
    _DOB=1
  else
    _DOB=0
  fi
  
  _REM=$(((4 - (_PAG % 4)) % 4))
  _TOT=$((_PAG + _REM))
  _MID=$((_TOT/2))
  _MIN=1
  _MAJ=$_TOT
  _OUT=""
  for _I in $(seq 1 $_MID)
  do
    if [[ $((_I % 2)) -eq 0 ]]
    then
      _OUT="$_OUT $_MIN $_MAJ"
      if [ $_DOB = 1 ]
      then
        _OUT="$_OUT $_MIN $_MAJ"
      fi
    else
      _OUT="$_OUT $_MAJ $_MIN"
      if [ $_DOB = 1 ]
      then
        _OUT="$_OUT $_MAJ $_MIN"
      fi
    fi
    _MIN=$((_MIN+1))
    _MAJ=$((_MAJ-1))
  done
  if [ $_REM -eq 3 ]
  then
      _I=$((_TOT - 3))
      _OUT=$(echo $_OUT | sed "s/\ $_I\ /\ $_BLA\ /g")
      _1verb "3 -- $_I in $_OUT"
  fi
  if [ $_REM -ge 2 ]
  then
      _I=$((_TOT - 2))
      _OUT=$(echo $_OUT | sed "s/\ $_I\ /\ $_BLA\ /g")
      _1verb "2 -- $_I in $_OUT"
  fi
  if [ $_REM -ge 1 ]
  then
      _I=$((_TOT - 1))
      _OUT=$(echo $_OUT | sed "s/\ $_I\ / $_BLA /g")
      _OUT=$(echo $_OUT | sed "s/$_TOT/$_PAG/g")
      _1verb "1 -- $_I in $_OUT"
  fi
  echo $_OUT
}

# Make a booklet from a PDF file
# @param PDF input file
# @param single (empty) or double (not empty)
function 1pdfbkl {
  local _INF _OUF _PAG _TMP _SEQ _MOD _DOB
  if 1check pdfinfo pdfjam
  then
    if [ $# -gt 1 ]
    then
      _MOD="2x2"
      _DOB="double"
    else
      _MOD="2x1 --landscape"
      _DOB=""
    fi
    _INF="$1"
    _OUF=$(echo "$_INF" | sed 's/\.pdf/-booklet.pdf/')
    _PAG=$(pdfinfo $_INF | grep Pages | xargs | cut -d\  -f 2)
    _SEQ=$(1booklet $_PAG BLANK $_DOB | tr ' ' ',' | sed 's/BLANK/\{\}/g')
    _TMP=$(mktemp -u)".pdf"
    _1verb "Input file $_INF with $_PAG pages, output $_OUF. Sequence: $_SEQ Temp file: $_TMP"
    pdfjam "$_INF" "$_SEQ" -o "$_TMP"
    pdfjam --nup $_MOD "$_TMP" --outfile "$_OUF"
    rm $_TMP
  fi
}