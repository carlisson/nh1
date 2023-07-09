#!/bin/bash

TDIR="$(dirname "${BASH_SOURCE[0]}")"
TREPEAT=10 #Random test: repeats X times

NH1=$(grep nh1 ~/.bashrc | sed 's/source\ //')

testPass() {
  local pass1 pass2
  pass1="$($NH1 pass)"
  pass2="$($NH1 pass)"
  assertNotEquals "1pass not working" "$pass1" "$pass2"
  assertEquals "Password with different sizes" "${#pass1}" "${#pass2}"
  assertTrue "Password too short" "[ ${#pass1} -gt 8 ]"
  assertTrue "Error message. Check it!" "[ $($NH1 pass | wc -l) -eq 1 ]"
}

testDiceware() {
  local pass1 pass2
  pass1="$($NH1 diceware)"
  pass2="$($NH1 diceware)"
  assertNotEquals "1diceware not working" "$pass1" "$pass2"
  assertEquals "Password with different sizes" $(echo "$pass1" | wc -w) $(echo "$pass2" | wc -w)
  assertTrue "Password too short" "[ $(echo "$pass1" | wc -w) -gt 3 ]"
  assertTrue "Error message. Check it!" "[ $($NH1 diceware | wc -l) -eq 1 ]"
}

testDW() {
  local pass1 pass2
  pass1="$(timeout 3 $NH1 dw)"
  assertEquals "1dw in looping" "0" "$?"
  pass2="$(timeout 3 $NH1 dw)"
  assertEquals "1dw in looping" 0 $?
  assertNotEquals "1dw not working" "$pass1" "$pass2"
  assertEquals "Password with different sizes" $(echo "$pass1" | wc -w) $(echo "$pass2" | wc -w)
  assertTrue "Password too short" "[ ${#pass1} -gt 5 ]"
  assertTrue "Error message. Check it!" "[ $(timeout 3 $NH1 dw | wc -l) -eq 1 ]"
}

testColor() {
  local color1 color2
  color1="$($NH1 color)"
  color2="$($NH1 color)"
  assertNotEquals "1color not working" "$color1" "$color2"
  assertTrue "This color is not ok" "[[ $color1 =~ ^[0-9A-Fa-f]{6}$ ]]"
}

testPdfOpt() {
  local pdffile="$TDIR/example.pdf"
  local pdfoptf="$TDIR/example-opt.pdf"
  assertTrue "PDF Example file not found" "[ -f $pdffile ]"
  if [ -f "$pdfoptf" ]
  then 
    rm "$pdfoptf"
  fi
  pushd "$TDIR" > /dev/null
  $NH1 pdfopt example.pdf
  popd > /dev/null
  assertTrue "Optimized PDF not created" "[ -f $pdfoptf ]"
  assertTrue "Optimized file is too big" "[ $(stat -c%s $pdffile) -gt $(stat -c%s $pdfoptf) ]"
  if [ -f "$pdfoptf" ]
  then
    rm "$pdfoptf"
  fi
}

testAJoin() {
  assertEquals "um" "$($NH1 ajoin , um)"
  assertEquals "um,dois" "$($NH1 ajoin , um dois)"
  assertEquals "1,2,3" "$($NH1 ajoin , 1 2 3)"
  assertEquals "1=2=3=4" "$($NH1 ajoin = 1 2 3 4)"
  assertEquals "um:dois" "$($NH1 ajoin : um dois)"
  assertEquals "10203040506070809" "$($NH1 ajoin 0 1 2 3 4 5 6 7 8 9)"
}

testEscape() {
  local fori="/tmp/action#.txt"
  local fdes="/tmp/action_.txt"
  touch "$fori"
  $NH1 escape "$fori"
  assertTrue "File not generated" "[ -f \"$fdes\" ]"
  rm -f "$fori" "$fdes"
  fori="/tmp/action th-Test10%.txt"
  fdes="/tmp/action_th_Test10_.txt"
  rm -f "$fori" "$fdes"
  touch "$fori"
  $NH1 escape "$fori"
  assertTrue "File not generated" "[ -f \"$fdes\" ]"  
  rm -f "$fori" "$fdes"
  fori="/tmp/action321XP.txt"
  touch "$fori"
  $NH1 escape "$fori"
  assertTrue "File not generated" "[ -f \"$fori\" ]"  
  rm -f "$fori"
}

testTip() {
  local tip=$($NH1 tip)
  assertTrue "1tip failed" $?
  assertTrue "1tip generated a empty string" "[ ${#tip} -gt 0 ]"
}

testSpChar() {
  local i char
  for i in $(seq 1 $TREPEAT)
  do
    char="$($NH1 spchar)"
    assertEquals "1spchar returns a big string" 1 ${#char}
    case $char in
      \"|\*|\\|\{|\}|\^|ª|\-|\+|\¬)
        char="_"
        ;;
    esac
    assertTrue "1spchar returns non-special char" "! [[ \"$char\" == ['0-9a-zA-Z'] ]]"
  done
}

testBooklet() {
  assertEquals "Booklet for 4 pages" "4 1 2 3" "$($NH1 booklet 4)"
  assertEquals "Booklet for 5 pages" "5 1 2 5 5 3 4 5" "$($NH1 booklet 5)"
  assertEquals "Booklet for 5 pages, blank=2" "2 1 2 2 2 3 4 5" "$($NH1 booklet 5 2)"
  assertEquals "Booklet for 6 pages" "6 1 2 6 6 3 4 5" "$($NH1 booklet 6)"
  assertEquals "Booklet for 7 pages" "7 1 2 7 6 3 4 5" "$($NH1 booklet 7)"
  assertEquals "Booklet for 12 pages" "12 1 2 11 10 3 4 9 8 5 6 7" "$($NH1 booklet 12)"
  assertEquals "Booklet for 4 pages, blank=2, double" "4 1 4 1 2 3 2 3" "$($NH1 booklet 4 2 double)"
  assertEquals "Booklet for 5 pages, blank=4, double" "4 1 4 1 2 4 2 4 4 3 4 3 4 5 4 5" "$($NH1 booklet 5 4 double)"
  assertEquals "Booklet for 6 pages, blank=2, double" "2 1 2 1 2 2 2 2 6 3 6 3 4 5 4 5" "$($NH1 booklet 6 2 double)"
  assertEquals "Booklet for 7 pages, blank=6, double" "6 1 6 1 2 7 2 7 6 3 6 3 4 5 4 5" "$($NH1 booklet 7 6 double)"
  assertEquals "Booklet for 12 pages, blank=2, double" "12 1 12 1 2 11 2 11 10 3 10 3 4 9 4 9 8 5 8 5 6 7 6 7" "$($NH1 booklet 12 2 double)"
}

testTr() {
  local i
  local c
  local strb stra # string-before and stringe-after

  strb="1 2 3 testing 45,6 then 9 or 8 or 7 too."
  for i in $(seq 0 9)
  do
    c='x'
    stra="$(echo "$strb" | tr $i x)"
    assertEquals "Digit check ($i)" "$stra" "$(echo "$strb" | $NH1 tr $i x)"
  done

  strb="The book is on the table. ABC or 80! 1+2=3 (Is this working?)"
  for i in {a..z}
  do
    c='?'
    stra="$(echo "$strb" | tr $i "$c")"
    assertEquals "Alphabetic char check ($i)" "$stra" "$(echo "$strb" | $NH1 tr $i "$c")"
  done
  for i in {A..Z}
  do
    c='?'
    stra="$(echo "$strb" | tr $i "$c")"
    assertEquals "Alphabetic char check ($i)" "$stra" "$(echo "$strb" | $NH1 tr $i "$c")"
  done
  for i in ' ' '.' ',' ';' ':' '!' '?' '(' ')' '-' '+' '=' '%'
  do
    c='0'
    stra="$(echo "$strb" | tr "$i" "$c")"
    assertEquals "Simple special char check ($i)" "$stra" "$(echo "$strb" | $NH1 tr "$i" "$c")"
  done

  strb="Sábado faço 10% da 1ª atividade"
  assertEquals "Special char check (á)" "Sabado faço 10% da 1ª atividade" "$(echo "$strb" | $NH1 tr "á" 'a')"
  assertEquals "Special char check (ç)" "Sábado faco 10% da 1ª atividade" "$(echo "$strb" | $NH1 tr "ç" 'c')"
  assertEquals "Special char check (ª)" "Sábado faço 10% da 1a atividade" "$(echo "$strb" | $NH1 tr "ª" 'a')"
}

# Load shUnit2.
if [ -f "$HOME/bin/shunit2" ]
then
    . $HOME/bin/shunit2
else
    . /usr/local/bin/shunit2
fi