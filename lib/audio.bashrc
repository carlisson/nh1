#!/bin/bash

# ALIASES

# Generate partial menu (for audio functions)
function _nh1audio.menu {
  1tint $WC "1id3get"
  echo             "  Extract metadata from an MP3 to a TXT"
  1tint $WC "1id3set"
  echo             "  Create a new MP3 file applying metadata from a TXT"
  1tint $XC "1ogg2mp3"
  echo              " Convert a ogg file to mp3"
  1tint $WC "1svideo"
  echo             "  Create static video from MP3 and PNG"
  1tint $XC "1talkbr"
  echo             "  Convert Portuguese text to WAV"
  1tint $WC "1yt3"
  echo          "     Extract Youtube video to MP3"
}

# Destroy all global variables created by this file
function _nh1audio.clean {
  unset -f _nh1audio.menu _nh1audio.clean 1id3get 1id3put 1svideo
  unset -f 1ogg2mp3 1talkbr 1yt3
}

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
      unset CIN COUT CMD
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
  if 1check ffmpeg
  then
    if [ $# -eq 3 ]
    then
      SVMIN="$1"
      SVPIN="$2"
      SVMOUT="$3"
	    ffmpeg -loop 1 -i "$SVPIN" -i "$SVMIN" -c:v libx264 -c:a aac \
        -strict experimental -b:a 192k -shortest "$SVMOUT"
      unset SVMIN SVPIN SVMOUT
    else
      echo "Call like this: 1svideo <MP3-input> <PNG-input> <MP4-output>"
    fi
  fi
}

# Convert ogg file to mp3
# @param Ogg input file
# @param MP3 input file (optional)
function 1ogg2mp3 {
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
      unset OGF MPF
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
      unset YTITLE YFILE YLOCAL YTMPDIR YVID
    else
      echo "You need to give one or more youtube video URLs"
    fi
  fi
}
