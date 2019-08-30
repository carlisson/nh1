#!/bin/bash

#ALIASES
_1IPERFPORT=2918

# Generate partial menu (for Network functions)
function _nh1network.menu {
  1tint $XC "1host"
  echo           "    Return a valid ping-available IP for some host or domain name"
  1tint $XC "1isip"
  echo           "    Return if a given string is an IP address"
  1tint $XC "1iperf"
  echo            "   Run iperf connecting to a 1iperfd IP"
  1tint $XC "1iperfd"
  echo             "  Run iperfd, waiting for 1iperf connection"
  1tint $XC "1tcpdump"
  echo             "  Run tcpdump in a given network interface"
  1tint $PC "1ports"
  echo
}

# Check if a string is an IP address
# @param String to test
function 1isip {
  if [ $# -eq 1 ]
  then
    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
    then
      return 0
    else
      return 1
    fi
  else
    echo "You need to give a string to test if it is an IP address."
  fi
}

# Check files .hosts in lib/local and lib/remote, for a name, returning a valid IP
# @param Host name you need an IP
function 1host {
	if [ $# -eq 1 ]
	then
		HNAM=$1
    if 1isip "$HNAM"
    then
      echo "$HNAM"
      unset HNAM
      return 0
    fi
    if HLIN=$(cat $(find "$_1LIB" -name "*.hosts") | grep "$HNAM ")
    then
			for HIP in ${HLIN/$HNAM/}
			do
				if ping -c 1 "$HIP" > /dev/null
				then
					echo "$HIP"
          unset HNUM HLIN
					return 0
				fi
			done
    fi
    if HLIN=$(dig +short "$HNAM" | xargs)
    then
      for HIP in ${HLIN/$HNAM/}
			do
				if ping -c 1 "$HIP" > /dev/null
				then
					echo "$HIP"
          unset HNUM HLIN
					return 0
				fi
			done
    fi
		echo "$HNAM is unkown or unavailable."
    unset HNAM
		return 1
	else
		echo "You need to put a machine name"
	fi
}

# Run iperf with a simple and functional configuration, connecting iperfd IP
# @param IP of a machine running 1iperfd
function 1iperf {
  if 1check iperf
  then
    if [ $# -eq 1 ]
    then
      HNAM=$(1host $1)
      _1verb "Trying to connect $HNAM ($1) with iperf"
      iperf -P 1 -i 5 -p "$_1IPERFPORT" -f M -t 60 -T 1 -c "$HNAM"
      unset HNAM
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

# Run tcpdump with a simple and functional configuration
# @param Interface to listen
function 1tcpdump {
  if 1check tcpdump
  then
  	if [ "$#" == 1 ]
  	then
  		INFA=$1
  	else
  		INFA=$(ip address show | grep ^2: |  cut -f 2 -d :)
  	fi
  	tcpdump -c 100 -nv -i $INFA
    unset INFA
  	return $?
  else
    return 1
  fi
}
