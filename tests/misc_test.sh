#!/bin/bash

TDIR="$(dirname "${BASH_SOURCE[0]}")"

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
  $NH1 pdfopt "$pdffile"
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

# Load shUnit2.
if [ -f "$HOME/bin/shunit2" ]
then
    . $HOME/bin/shunit2
else
    . /usr/local/bin/shunit2
fi