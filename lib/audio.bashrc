#!/bin/bash

# ALIASES

# Generate partial menu (for audio functions)
function _nh1audio.menu {
  1tint $XC "1id3get"
  echo              " Extract metadata from an MP3 to a TXT"
  1tint $XC "1id3set"
  echo              " Create a new MP3 file applying metadata from a TXT"
  1tint $PC "1yt3"
  echo           "    ca"
}

# Destroy all global variables created by this file
function _nh1audio.clean {
  unset -f _nh1audio.menu _nh1audio.clean 1id3get 1id3put
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
