#!/bin/bash

#cd "$(dirname "${BASH_SOURCE[0]}")"

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
  pass1="$($NH1 dw)"
  pass2="$($NH1 dw)"
  assertNotEquals "1dw not working" "$pass1" "$pass2"
  assertEquals "Password with different sizes" $(echo "$pass1" | wc -w) $(echo "$pass2" | wc -w)
  assertTrue "Password too short" "[ ${#pass1} -gt 5 ]"
  assertTrue "Error message. Check it!" "[ $($NH1 dw | wc -l) -eq 1 ]"
}

# Load shUnit2.
if [ -f "$HOME/bin/shunit2" ]
then
    . $HOME/bin/shunit2
else
    . /usr/local/bin/shunit2
fi