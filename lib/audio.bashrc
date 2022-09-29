#!/bin/bash

# Generate partial menu (for audio functions)
function _nh1audio.menu {
  echo "___ Audio ___"
  _1menuitem W 1alarm "Play an audio alarm" speaker-test
  _1menuitem W 1beat "Play a simple beat in given frequency" speaker-test
  _1menuitem X 1genbigmp3 "Append various MP3 files in one single file" ffmpeg
  _1menuitem W 1id3get "Extract metadata from an MP3 to a TXT" ffmpeg
  _1menuitem W 1id3set "Create a new MP3 file applying metadata from a TXT" ffmpeg
  _1menuitem X 1ogg2mp3 "Convert a ogg file to mp3" ffmpeg
  _1menuitem W 1svideo "Create static video from MP3 and PNG" ffmpeg
  _1menuitem X 1talkbr "Convert Portuguese text to WAV" espeak
  _1menuitem W 1yt3 "Extract Youtube video to MP3" youtube-dl ffmpeg
}

# Destroy all global variables created by this file
function _nh1audio.clean {
  unset -f _nh1audio.menu _nh1audio.clean 1alarm 1id3get 1id3put 1svideo
  unset -f 1ogg2mp3 1talkbr 1yt3 1beat 1id3set 1genbigmp3 _nh1audio.complete
  unset -f _nh1audio.complete.id3get _nh1audio.complete.id3set
  unset -f _nh1audio.complete.svideo _nh1audio.complete.ogg2mp3
}

function _nh1audio.complete {
  complete -F _nh1audio.complete.id3get 1id3get
  complete -F _nh1audio.complete.id3set 1id3set
  complete -F _nh1audio.complete.svideo 1svideo
  complete -F _nh1audio.complete.ogg2mp3 ogg2mp3
}

function _nh1audio.complete.id3get { _1compl 'mp3' 0 0 0 0 ; }
function _nh1audio.complete.id3set { _1compl 'mp3' 'txt' 0 0 0 ; }
function _nh1audio.complete.svideo { _1compl 'mp3' 'png' 0 0 0 ; }
function _nh1audio.complete.ogg2mp3 { _1compl 'ogg' 0 0 0 0 ; }

# Extract ID3V2 metadata from an MP3 file
# @param MP3 input file
# @param TXT output file
function 1id3get {
  if 1check ffmpeg
  then
    if [ $# -eq 2 ]
    then
      ffmpeg -i "$1" -f ffmetadata "$2" &> /dev/null
    else
      echo "You need to give 2 params: 1id3get <MP3-Input> <TXT-Output>"
    fi
  fi
}

# Apply ID3V2 metadata into a MP3 file
# @param MP3 input file
# @param TXT input file
# @param MP3 output file (optional)
function 1id3set {
  local CIN COUT CMD
  if 1check ffmpeg
  then
    if [ $# -gt 1 ]
    then
      CIN=$1
      CMD=$2
      if [ $# -eq 3 ]
      then
        COUT=$3
      else
	      COUT=`basename "$CIN" .mp3`'-c.mp3'
      fi
	    ffmpeg -i "$CIN" -i "$CMD" -map_metadata 1 -c:a copy \
        -id3v2_version 3 -write_id3v1 1 "$COUT" &> /dev/null
    else
      echo "You need to give 2 or 3 params."
      echo " 1) MP3 input file"
      echo " 2) TXT metadata input file"
      echo " 3) (optional) MP3 output file. Default: <input>-c.mp3"
    fi
  fi
}

# Create a static video from a MP3 and an image
# @param MP3 input file
# @param PNG input file
# @param MP4 output file
function 1svideo {
  local SVMIN SVPIN SVMOUT
  if 1check ffmpeg
  then
    if [ $# -eq 3 ]
    then
      SVMIN="$1"
      SVPIN="$2"
      SVMOUT="$3"
	    ffmpeg -loop 1 -i "$SVPIN" -i "$SVMIN" -c:v libx264 -c:a aac \
        -strict experimental -b:a 192k -shortest "$SVMOUT"
    else
      echo "Call like this: 1svideo <MP3-input> <PNG-input> <MP4-output>"
    fi
  fi
}

# Convert ogg file to mp3
# @param Ogg input file
# @param MP3 output file (optional)
function 1ogg2mp3 {
  local OGF MPF
  if 1check ffmpeg
  then
    if [ $# -gt 1 ]
    then
      OGF="$1"
      if [ $# -eq 2 ]
      then
        MPF="$2"
      else
        MPF=`basename "$1" .ogg`'.mp3'
      fi
  	  ffmpeg -i "$OGF" "$MPF"
  	  rm "$OGF"
    else
      echo "You need to info OGG input file and (optional) MP3 output"
    fi
  fi
}

# Create a WAV file from an string
# @param Message
# @param WAV output file
function 1talkbr {
  if 1check espeak
  then
    if [ $# -eq 2 ]
    then
      espeak -v brazil-mbrola-1 "$1" -w "$2"
    else
      echo "Use: 1talkbr 'Message' <WAV-output>"
    fi
  fi
}

# Create a MP3 file from a youtube video
# @param Youtube video URL(s)
function 1yt3 {
  local YTITLE YFILE YLOCAL YTMPDIR YVID
  if 1check youtube-dl ffmpeg
  then
    if [ $# -gt 0 ]
    then
      YTMPDIR=$(mktemp -d)
      YLOCAL=$(pwd)

      for YURL in $*
      do
    	  YTITLE=`youtube-dl -e "$YURL"`
    	  YFILE="$YTITLE.mp3"

    	  cd "$YTMPDIR"
    	  youtube-dl "$YURL"
    	  YVID=`ls | head -1`

    	  cd "$YLOCAL"
    	  ffmpeg -i "$YTMPDIR/$YVID" -metadata title="$YTITLE" "$YFILE"
    	  rm -f "$YTMPDIR/*"
    	  echo `date` ':' "$YTITLE" >> .yt3.log
      done

      rm -rf "$YTMPDIR"
    else
      echo "You need to give one or more youtube video URLs"
    fi
  fi
}

# Play a simple beat with 0.2 seconds, in given frequency
# @param Frequency
function 1beat {
  ( \speaker-test --frequency $1 --test sine >/dev/null)&
  pid=$!
  \sleep 0.200s
  \kill -9 $pid
}

# Sound a simple audio alarm
function 1alarm {
  for i in `seq 400 100 700`
  do
    1beat $i 2> /dev/null
  done
}

# Create a single random mp3 from various mp3
# @param input dir with the original music files
# @param output filename
function 1genbigmp3 {
  local OLDIFS IFS f i PBN NUMB
  if 1check ffmpeg
  then
    if [ $# -eq 2 ]
    then
      PBN="$2"
      OLDIFS="$IFS"
      IFS=$'\n'

      for f in $(find $1/* -name '*.mp3')
      do
        1escape $f
      done

      pushd $1 > /dev/null

      for i in $(ls *.mp3)
      do
        NUMB=$(1d100)
        ffmpeg -i "$i" "$NUMB-$i.ogg"
      done

      cat *.ogg > final.ogg

      IFS="$OLDIFS"

      popd > /dev/null

      ffmpeg -i $1/final.ogg $2
      rm -f $1/*.ogg
    else
      echo Usage: 1genbigmp3 [DIRECTORY-WITH-INPUT-MP3-FILES] [OUTPUT.mp3]
    fi
  fi
}
