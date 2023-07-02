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
  echo $pdffile $pdfoptf
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

# Load shUnit2.
if [ -f "$HOME/bin/shunit2" ]
then
    . $HOME/bin/shunit2
else
    . /usr/local/bin/shunit2
fi