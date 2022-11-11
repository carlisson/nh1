#!/bin/bash
# @file misc.bashrc
# @brief Miscelania

_1MISCLOCAL="$_1UDATA/misc"
_1MISCTIPS="$_1MISCLOCAL"
_1MISCPOMOMIN=25

# @description Generate partial menu
_nh1misc.menu() {
  _1menuheader "$(_1text "Miscelania")"
  _1menuitem X 1ajoin "$(_1text "Join an array, using first param as delimiter")"
  _1menuitem W 1booklet "$(_1text "Generate a seq for booklet, for given page number")"
  _1menuitem W 1color "$(_1text "Generate a random hexadecimal color")" openssl
  _1menuitem W 1diceware "$(_1text "Generate a random diceware password")"
  _1menuitem W 1du "$(_1text "Disk usage")" du
  _1menuitem W 1escape "$(_1text "Rename a file or dir, excluding special chars")"
  _1menuitem W 1pass "$(_1text "Generate a secure password")" openssl
  _1menuitem W 1pdfbkl "$(_1text "Make a booklet form a PDF file")" pdfjam
  _1menuitem W 1pdfopt "$(_1text "Compress a PDF file")" gs
  _1menuitem W 1pomo "$(printf "$(_1text "Run one pomodoro (default is %s min)")" "$_1MISCPOMOMIN")" seq
  _1menuitem W 1power "$(_1text "Print percentage for battery (notebook)")" upower
  _1menuitem W 1rr30 "$(_1text "Counter 30-30-30 to router reset")" seq
  _1menuitem X 1spchar "$(_1text "Returns a random special character")"
  _1menuitem W 1timer "$(_1text "Countdown timer.")" seq
  _1menuitem X 1tip "$(_1text "Shows a random tip")" shuf
}

# @description Destroy all global variables created by this file
_nh1misc.clean() {
  unset _1MISCLOCAL _1MISCTIPS _1MISCPOMOMIN
  unset -f 1color 1du 1pass 1escape 1timer 1rr30 1tip 1spchar
  unset -f _nh1misc.menu _nh1misc.clean 1power 1pdfopt 1ajoin 1pomo
  unset -f 1booklet 1pdfbkl _nh1misc.complete _nh1misc.complete.pdfbkl
  unset -f _nh1misc.customvars _nh1misc.info _nh1misc.complete.from_pdf
  unset -f _nh1misc.init 1diceware
}

# @description Autocompletion
_nh1misc.complete() {
  local _AUX
  complete -F _nh1misc.complete.from_pdf 1pdfbkl
  complete -F _nh1misc.complete.from_pdf 1pdfopt
  complete -W "$(_1vardb.show "timer" "list")" 1timer
	complete -W "$(_1list $_1MISCTIPS "tips")" 1tip
  _AUX=$(_1list $_1MISCTIPS "tips")
  if [ -n "$_AUX" ]
  then
    complete -W "$_AUX" 1tip
  fi
}

# @description Load variables defined by user
_nh1misc.customvars() {
  _1customvar NORG_POMODORO_MINS _1MISCPOMOMIN number
  _1customvar NORG_TIPS_DIR _1MISCTIPS
}

# @description Information about custom vars
_nh1misc.info() {
  _1menuitem W NORG_POMODORO_MINS "$(printf "$(_1text "Duration of a Pomodoro (%s). Default: %s min.")" "1pomo" "25")"
  _1menuitem W NORG_TIPS_DIR "$(_1text "Path for tip groups (text files).")"
}

# @description Initialization
_nh1misc.init() {
  mkdir -p "$_1MISCLOCAL"
  mkdir -p "$_1MISCTIPS"
  _1vardb.init "timer"
}

# @description Completion for functions with pdf input
_nh1misc.complete.from_pdf() { _1compl 'pdf' 0 0 0 0 ; }

# @description Print percentage for battery charge
1power() {
	_1before
  if 1check upower
  then
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage
  fi
}

# Alias like
# @description Disk usage
1du() { du -h -d 1 ; }

# @description Random password generator. 12chars=72bits entropy
1pass()  {
	_1before
  openssl rand -base64 16 | rev | cut -c 3-14
}

# @description Random diceware password generator. 6words=77bits entropy
1diceware() {
	_1before
  local _LANG _DFILE _ROLL _WORDS _PASS _I _J
  _WORDS=6
  _LANG="$(echo $LANG | cut -d\. -f 1 | cut -d_ -f 1)"
  _DFILE="$_1LIB/diceware/diceware.wordlist.txt"
  if [ -f "$_1LIB/diceware/diceware.wordlist.$_LANG.txt" ]  
  then
    _DFILE="$_1LIB/diceware/diceware.wordlist.$_LANG.txt"
  fi
  _PASS=""
  for _I in $(seq 1 $_WORDS)
  do
    _ROLL=""
    for _J in $(seq 1 5)
    do
      _ROLL="$_ROLL$(1d6)"
    done
    _PASS="$_PASS $(grep $_ROLL "$_DFILE" | sed 's/[1-6]*[\ \t]*//')"
  done
  echo $_PASS
}

# dwd12 entropy: 4words + 2special (40 options)=68bits, +secret=?bits

# @description Random color generator
1color() {
 	_1before
  openssl rand -hex 3
}

# @description Compress PDF file
# @arg $1 string PDF input file
# @arg $2 string PDF output file (optional)
1pdfopt() {
	_1before
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
    	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH \
        -dPrinted=false -dSubsetFonts=true -dCompressFonts=true -dEmbedAllFonts=true -dDetectDuplicateImages=true \
        -dColorImageDownsampleType=/Bicubic -dColorImageResolution=300 -dGrayImageDownsampleType=/Bicubic \
        -dGrayImageResolution=300 -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=300 \
        -dDownsampleColorImages=true -sProcessColorModel=DeviceRGB -sColorConversionStrategy=RGB \
        -sColorConversionStrategyForImages=RGB -dConvertCMYKImagesToRGB=true \
        -sOutputFile=$OUF $INF
    else
      printf "$(_1text "Usage: %s.")\n" "1pdfopt <PDF-input> <PDF-output optional>"
    fi
  fi
}

# @description Join an array, using first param as delimiter
# @arg $1 string delimiter, character
# @arg $2 string other values to join
1ajoin() {
  local IFS="$1"
  shift
  echo "$*"
}

# @description Countdown timer
# @arg $1 int color for timer (0 to 7)
# @arg $2 string title for timer
# @arg $3 int seconds (optional)
# @arg $4 int minutes (optional)
# @arg $5 int hours to countdown (optional)
1timer() {
	_1before
  local HOURS MINUTES SECONDS TITLE COLOR CLOCK IH IM IS UNCLOCK IU AUX
  AUX=""
  if [ $# -eq 1 ]
  then
    AUX=$(_1vardb.get timer "$1")
    if [ $? -eq 0 ]
    then
      TITLE="$1"
      COLOR=$(echo $AUX | sed 's/\(.*\) \(.*\):\(.*\):\(.*\)/\1/')
      HOURS=$(echo $AUX | sed 's/\(.*\) \(.*\):\(.*\):\(.*\)/\2/')
      MINUTES=$(echo $AUX | sed 's/\(.*\) \(.*\):\(.*\):\(.*\)/\3/')
      SECONDS=$(echo $AUX | sed 's/\(.*\) \(.*\):\(.*\):\(.*\)/\4/')
    else
      AUX="usage"
    fi
  else
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
    else
      AUX="usage"
    fi
  fi

  if [ "$AUX" = "usage" ]
  then
    _1text "Usage:"
    echo "  1timer <COLOR> <TITLE> <SECONDS> <MINUTES> <HOURS>"
    echo "  1timer <NAME>"
    _1menuheader "$(_1text "Available timers")"
    _1vardb.show timer
  else
    UNCLOCK=""

    1tint $COLOR "$TITLE"

    _1vardb.set timer "$TITLE" "$COLOR $HOURS:$MINUTES:$SECONDS"
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
        IM="$(printf "%.0f" "$IM")" # forcing decimal syntax (not octal)
        IM=$((IM-1))
      done
      MINUTES=59
      IH="$(printf "%.0f" "$IH")" # forcing decimal syntax (not octal)
      IH=$((IH-1))        
    done
    echo -e "$UNCLOCK" "$(_1text "finished")"
  fi
}

# @description Create a Pomodore in shell
# @arg $1 int minutes to pomodoro (default 25)
# @see 1timer
1pomo() {
  local MINUTES
  
  MINUTES=$_1MISCPOMOMIN
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

# @description Timer to help to reset a router, using the 30-30-30 method
# @see 1timer
1rr30() {
  echo
  1tint 3 "$(_1text "30-30-30 method for router reseting")"
  echo " - $(_1text "your router will lost all configuration")"
  echo " 1. $(_1text "Turn on the router.")"
  echo " 2. $(_1text "Press and hold reset button. Wait 30 seconds.")"
  echo " 3. $(_1text "Turn off the router. Wait 30 seconds.")"
  echo " 4. $(_1text "Turn on the router. Wait 30 seconds.")"
  echo " 5. $(_1text "Release the button")"
  1tint 3 "$(_1text "Press ENTER when you are ready.")"
  read
  1timer 2 "$(_1text "Router on")" 30
  1alarm
  1timer 4 "$(_1text "Router off")" 30
  1alarm
  1timer 2 "$(_1text "Router on")" 30
  1alarm
  echo
  _1text "Your router must be restarted with factory settings!"
}

# @description Rename a file or directory, removing special chars
# @arg $1 string file
1escape() {
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

# @description Shows a random tip to the user
# @arg $1 string Group of tip ("list" to list all groups)
# @exitcode 0 It works
# @exitcode 1 Tip file not found
1tip() {
	_1before
  local _TFIL
  if [ ! -d "$_1MISCTIPS" ]
  then
    mkdir "$_1MISCTIPS"
    cp "$_1LIB/templates/norg.tips" "$_1MISCTIPS"
  fi
	if [ $# -eq 0 ]
	then
		cat $_1MISCTIPS/*.tips | shuf | head -1
	else
		if [ "$1" = "list" ]
		then
			printf "$(_1text "Tip groups: %s.")\n" "$(_1list $_1MISCTIPS "tips")"
			
    else
      _TFIL=$_1MISCTIPS/$1.tips
      if [ -f "$_TFIL" ]
      then
        shuf "$_TFIL" | head -1
      else
        printf "$(_1text "No tips group %s found.")\n" $1
        return 1
      fi
    fi
	fi
	return 0
}

# @description Returns a random special character
# @stdout A special char
1spchar() {
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


# @description Generates a seq of pages to make booklet (4 pages i 2-sides paper)
# @arg $1 int Number of pages
# @arg $2 int Number of the "blank" page. Default: last
# @arg $3 string Mode single or double. Default: single. Any-arg: double.
# @stdout Pages sequence
# @see 1pdfbkl
1booklet() {
	_1before
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

# @description Make a booklet from a PDF file
# @arg $1 string PDF input file
# @arg $2 string single (empty) or double (not empty)
# @see 1booklet
1pdfbkl() {
	_1before
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
    _1verb "$(printf "$(_1text "Input file %s with %i pages, output %s. Sequence: %s Temp file: %s.")" $_INF $_PAG $_OUF $_SEQ $_TMP)"
    pdfjam "$_INF" "$_SEQ" -o "$_TMP"
    pdfjam --nup $_MOD "$_TMP" --outfile "$_OUF"
    rm $_TMP
  fi
}