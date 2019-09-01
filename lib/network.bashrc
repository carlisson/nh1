#!/bin/bash

#ALIASES
_1IPERFPORT=2918

# Generate partial menu (for Network functions)
function _nh1network.menu {
  echo "___ Network ___"
  _1menuitem W 1host "Return a valid ping-available IP for some host or domain name"
  _1menuitem X 1iperf "Run iperf connecting to a 1iperfd IP" iperf
  _1menuitem X 1iperfd "Run iperfd, waiting for 1iperf connection" iperf
  _1menuitem X 1isip "Return if a given string is an IP address"
  _1menuitem X 1ison "Return if server is on. Params: (-q for quiet or name), IP"
  _1menuitem X 1ssh "Connect a SSH server (working with eXtreme)" ssh
  _1menuitem X 1tcpdump "Run tcpdump in a given network interface" tcpdump
  _1menuitem P 1ports "to-do"
  echo
}

# Clean variables
function _nh1network.clean {
  unset _1IPERFPORT
  unset -f _nh1network.menu _nh1network.clean 1isip 1host 1iperf 1iperfd
  unset -f 1tcpdump 1ison _1pressh 1ssh
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

# Check using ping if machine is online
# @param Machine name (optional). -q if you need a quiet mode
# @param URI or IP
function 1ison {
  thehost=$(1host $2)
	if ping -q -c 1 -w 1 "$thehost" &> /dev/null
	then
		if [ $1 != "-q" ]
		then
			1tint 2 "$1 is active"
			echo
		fi
    unset thehost
		return 0
	else
		if [ $1 != "-q" ]
		then
			1tint 1 "$1 not found"
			echo
		fi
    unset thehost
		return 1
	fi
}

# Internal function, pre-1ssh
# @param server or user@server, to use with ssh
function _1pressh {
	if [ $(echo "$1" | grep "@") ]
	then
		aux_u=${1%@*}
		aux_h=${1#*@}
	else
		aux_u="admin"
		aux_h="$1"
	fi
	if ! $(1ison -q $aux_h)
	then
		if aux=$(1host "$aux_h")
		then
			aux_h=$aux
		fi
	fi
	echo "$aux_u@$aux_h"
  unset aux_u aux_h
}

# Access with SSH server (including extreme switchs)
# @param name or IP, or usr@IP
# @param Additional options for ssh
function 1ssh {
  if 1check ssh
  then
    _1verb "Conectando por SSH."
  	destip=$(_1pressh $1)
    finalstatus=1

  	# O método que não funcionar, o 7ssh testa o seguinte
    _1verb "Trying connect in simple mode"
  	ssh "$destip" $2
    if [ $? -eq 0 ]
    then
      finalstatus=0
    else
      _1verb "Trying connect using AES192"
      ssh -c aes192-cbc "$destip" $2
      if [ $? -eq 0 ]
      then
        finalstatus=0
      else
        _1verb "Trying connect with various options"
  		  ssh -c aes192-cbc -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-dss "$destip" $2
      fi
    fi
    if [ $finalstatus -eq 0 ]
    then
      _1verb "It works."
    else
      echo "Cannot connect with $1 using SSH"
    fi
    unset destip finalstatus
  fi
}
