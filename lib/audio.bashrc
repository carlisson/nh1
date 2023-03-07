#!/bin/bash
# @file audio.bashrc
# @brief Audio and audio files related funtions

# @description Generate partial menu (for audio functions)
_nh1audio.menu() {
  _1menuheader "$(_1text "Audio")"
  _1menuitem W 1alarm "$(_1text "Play an audio alarm")" speaker-test
  _1menuitem W 1beat "$(_1text "Play a simple beat in given frequency")" speaker-test
  _1menuitem W 1genbigmp3 "$(_1text "Append various MP3 files in one single file")" ffmpeg
  _1menuitem W 1id3get "$(_1text "Extract metadata from an MP3 to a TXT")" ffmpeg
  _1menuitem W 1id3set "$(_1text "Create a new MP3 file applying metadata from a TXT")" ffmpeg
  _1menuitem W 1ogg2mp3 "$(_1text "Convert a ogg file to mp3")" ffmpeg
  _1menuitem W 1svideo "$(_1text "Create static video from MP3 and PNG")" ffmpeg
  _1menuitem W 1talkbr "$(_1text "Convert Portuguese text to WAV")" espeak
  _1menuitem W 1yt3 "$(_1text "Extract Youtube video to MP3")" youtube-dl ffmpeg
}

# @description Destroy all global variables created by this file
_nh1audio.clean() {
  unset -f _nh1audio.menu _nh1audio.clean 1alarm 1id3get 1id3put 1svideo
  unset -f 1ogg2mp3 1talkbr 1yt3 1beat 1id3set 1genbigmp3 _nh1audio.complete
  unset -f _nh1audio.complete.id3get _nh1audio.complete.id3set
  unset -f _nh1audio.complete.svideo _nh1audio.complete.ogg2mp3
}

# @description Autocomplete config
_nh1audio.complete() {
  complete -F _nh1audio.complete.id3get 1id3get
  complete -F _nh1audio.complete.id3set 1id3set
  complete -F _nh1audio.complete.svideo 1svideo
  complete -F _nh1audio.complete.ogg2mp3 1ogg2mp3
}

# @description Autocomplete for 1id3get
# @see _nh1audio.complete
_nh1audio.complete.id3get() { _1compl 'mp3' 0 0 0 0 ; }

# @description Autocomplete for 1id3set
# @see _nh1audio.complete
_nh1audio.complete.id3set() { _1compl 'mp3' 'txt' 0 0 0 ; }

# @description Autocomplete for 1svideo
# @see _nh1audio.complete
_nh1audio.complete.svideo() { _1compl 'mp3' 'png' 0 0 0 ; }

# @description Autocomplete for 1ogg2mp3
# @see _nh1audio.complete
_nh1audio.complete.ogg2mp3() { _1compl 'ogg' 0 0 0 0 ; }

# @description Usage instructions
# @arg $1 string Public function name
_nh1audio.usage() {
  case $1 in
    beat)
      printf "$(_1text "Usage: %s <%s>")\n" "1$1" "$(_1text "audio frequency (int)")"        
      ;;
    genbigmp3)
      printf "$(_1text "Usage: %s <%s> <%s>")\n" "1$1" "$(_1text "directory with input mp3 files")" "$(_1text "output mp3 file")"
      ;;
    id3get)
      printf "$(_1text "Usage: %s <%s> <%s>")\n" "1$1" "$(_1text "MP3 input file")" "$(_1text "Text output file")"
      ;;
    id3set)
      printf "$(_1text "Usage: %s <%s> <%s> [%s]")\n" "1$1" "$(_1text "MP3 input file")" "$(_1text "TXT metadata input file")" "$(_1text "(optional) MP3 output file")"
      printf "  - $(_1text "Default output file: %s")\n" "<input>-c.mp3"
      ;;
    ogg2mp3)
      printf "$(_1text "Usage: %s <%s> [(%s) %s]")\n" "1$1" "$(_1text "input ogg file")" "$(_1text "optional")" "$(_1text "output mp3 file")"
      ;;
    svideo)
      printf "$(_1text "Usage: %s <%s> <%s> <%s>")\n" "1$1" "$(_1text "input mp3 file")" "$(_1text "input png file")" "$(_1text "output mp4 file")"
      ;;
  esac
}

# @description Extract ID3V2 metadata from an MP3 file
# @arg $1 string MP3 input file
# @arg $1 string TXT output file
# @see 1id3set
1id3get() {
	_1before
  if 1check ffmpeg
  then
    if [ $# -eq 2 ]
    then
      ffmpeg -i "$1" -f ffmetadata "$2" &> /dev/null
    else
      _nh1audio.usage id3get
    fi
  fi
}

# @description Apply ID3V2 metadata into a MP3 file
# @arg $1 string MP3 input file
# @arg $2 string TXT input file
# @arg $3 string MP3 output file (optional)
# @see 1id3get
1id3set() {
	_1before
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
      _nh1audio.usage id3set
    fi
  fi
}

# @description Create a static video from a MP3 and an image
# @arg $1 string MP3 input file
# @arg $2 string PNG input file
# @arg $3 string MP4 output file
1svideo() {
	_1before
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
      _nh1audio.usage svideo
    fi
  fi
}

# @description Convert ogg file to mp3
# @arg $1 string Ogg input file
# @arg $2 string MP3 output file (optional)
1ogg2mp3() {
	_1before
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
      _nh1audio.usage ogg2mp3
    fi
  fi
}

# @description Create a WAV file from an string
# @arg $1 string Message
# @arg $2 string WAV output file
1talkbr() {
	_1before
  if 1check espeak
  then
    if [ $# -eq 2 ]
    then
      espeak -v brazil-mbrola-1 "$1" -w "$2"
    else
      printf "$(_1text "Usage: %s.")\n" "1talkbr 'Message' <WAV-output>"
    fi
  fi
}

# @description Create a MP3 file from a youtube video
# @arg $1 string Youtube video URL(s)
1yt3() {
	_1before
  local YTITLE YFILE YLOCAL YTMPDIR YVID
  if 1check youtube-dl ffmpeg
  then
    if [ $# -gt 0 ]
    then
      YTMPDIR=$(mktemp -d)
      YLOCAL=$(pwd)

      for YURL in $*
      do
    	  YTITLE="$(youtube-dl -e "$YURL")"
    	  YFILE="$YTITLE.mp3"
        _1verb "$(printf "$(_1text "Downloading %s to file %s.")\n" "$YTITLE" "$YFILE")"

    	  cd "$YTMPDIR"
    	  youtube-dl -x "$YURL"
    	  YVID="$(ls | head -1)"
        _1verb "$(printf "$(_1text "Local file: %s.")\n" "$YVID")"

    	  cd "$YLOCAL"
    	  ffmpeg -i "$YTMPDIR/$YVID" -metadata title="$YTITLE" "$YFILE"
        1escape "$YFILE"
        
    	  rm -rf "$YTMPDIR"
        mkdir "$YTMPDIR"
        
    	  echo $(date) ':' "$YTITLE" >> .yt3.log
        _1verb "$(tail -1 .yt3.log)"
      done

      rm -rf "$YTMPDIR"
    else
      _1text "You need to give one or more youtube video URLs"
    fi
  fi
}

# @description Play a simple beat with 0.2 seconds, in given frequency
# @arg $1 int Frequency
1beat() {
  if [ $# -ne 1 ]
  then
    _nh1audio.usage beat
    return 0
  fi
  ( \speaker-test --frequency $1 --test sine >/dev/null)&
  pid=$!
  \sleep 0.200s
  \kill -9 $pid
}

# @description Sound a simple audio alarm
# @see 1beat
1alarm() {
  for i in `seq 400 100 700`
  do
    1beat $i 2> /dev/null
  done
}

# @description Create a single random mp3 from various mp3
# @arg $1 string input dir with the original music files
# @arg $2 string output filename
1genbigmp3() {
	_1before
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
      _nh1audio.usage genbigmp3
    fi
  fi
}
