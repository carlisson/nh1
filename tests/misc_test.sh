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
}

# Load shUnit2.
if [ -f "$HOME/bin/shunit2" ]
then
    . $HOME/bin/shunit2
else
    . /usr/local/bin/shunit2
fi