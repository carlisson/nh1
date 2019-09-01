#!/bin/bash

# Generate partial menu
function _nh1misc.menu {
  1tint $PC "1du"
  echo
  1tint $XC "1power"
  echo            "   Print percentage for battery (notebook)"
}

# Destroy all global variables created by this file
function _nh1misc.clean {
  unset -f _nh1misc.menu _nh1misc.clean 1power
}

# Print percentage for battery charge
function 1power {
  if 1check upower
  then
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage
  fi
}
