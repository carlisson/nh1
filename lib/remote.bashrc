#!/bin/bash

#ALIASES

# Generate partial menu
function _nh1remote.menu {
  echo "___ Remote ___"
  _1menuitem X 1remconnect "Configure connection to a server"
  _1menuitem P 1remhosts "Connect and get from server lists of hosts/ips"
  echo
}

# Clean variables
function _nh1remote.clean {
  unset -f _nh1remote.menu _nh1remote.clean 1remconnect
}

# server;block,block,block

# Configure connection to a server
# @param Server hostname or IP
function 1remconnect {
  if [ $# -eq 1 ]
  then
    IP=$(1host $1)
    if [ $? -eq 0 ]
    then
      if 1ports "$IP" "$_1REMPORT" &> /dev/null
      then
        local LIN LREV
        local LBLOCKS=""
        LIN=$(grep "^$IP\;" "$_1REMFILE")
        if [ $? -eq 0 ]
        then
          LBLOCKS=$(echo $LIN | cut -d\; -f 2 | tr ',' ' ')
          _1verb "Server $IP yet set. Following sections: $LBLOCKS."
        else
          local RDTEMP=$(mktemp -d)

          pushd $RDTEMP
          curl "http://$IP:$_1REMPORT/hosts/status" > $RDTEMP/status
          local RBLOCKS=$(cut -d\; -f 1 status | xargs)

          echo $IP\;$(echo "$RBLOCKS" | tr ' ' ',') >> $_1REMFILE

          popd

          $(rm -rf "$RDTEMP")
        fi
      fi
    else
      echo "Server $1 not found."
    fi
  else
    echo "Use this, informing a server to connect."
  fi
}
