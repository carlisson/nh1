#!/bin/bash

#ALIASES
_1IPERFPORT=2918

# Generate partial menu (for Network functions)
function _nh1network.menu {
  1tint $XC "1iperf"
  echo            "   Run iperf connecting to a 1iperfd IP"
  1tint $XC "1iperfd"
  echo             "  Run iperfd, waiting for 1iperf connection"
  1tint $PC "1ports"
  echo
}

# Run iperf with a simple and functional configuration, connecting iperfd IP
# @param IP of a machine running 1iperfd
function 1iperf {
  if 1check iperf
  then
    if [ $# -eq 1 ]
    then
      iperf -P 1 -i 5 -p "$_1IPERFPORT" -f M -t 60 -T 1 -c "$1"
    else
      echo "You need to put a IP address where 1iperfd is running."
    fi
  fi
}

# Run iperf with a simple and functional configuration, as daemon, wainting connection
function 1iperfd {
  if 1check iperf
  then
    iperf -s -P 2 -i 5 -p "$_1IPERFPORT" -f M
  fi
}
