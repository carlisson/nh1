#!/bin/bash

#ALIASES
_1IPERFPORT=2918

# Generate partial menu (for Network functions)
function _nh1network.menu {
  echo "___ Network ___"
  _1menuitem X 1allhosts "Returns all hosts in all your networks" ip ipcalc
  _1menuitem X 1findport "Search in all network every IP with given port open" ip ipcalc
  _1menuitem W 1host "Return a valid ping-available IP for some host or domain name"
  _1menuitem X 1iperf "Run iperf connecting to a 1iperfd IP" iperf
  _1menuitem X 1iperfd "Run iperfd, waiting for 1iperf connection" iperf
  _1menuitem X 1isip "Return if a given string is an IP address"
  _1menuitem X 1ison "Return if server is on. Params: (-q for quiet or name), IP"
  _1menuitem X 1mynet "Return all networks running on network interfaces" ip
  _1menuitem X 1ports "Scan 1.500 ports for a given host"
  _1menuitem X 1ssh "Connect a SSH server (working with eXtreme)" ssh
  _1menuitem X 1tcpdump "Run tcpdump in a given network interface" tcpdump
  echo
}

# Clean variables
function _nh1network.clean {
  unset _1IPERFPORT
  unset -f _nh1network.menu _nh1network.clean 1isip 1host 1iperf 1iperfd
  unset -f 1tcpdump 1ison _1pressh 1ssh 1ports 1findport 1allhosts 1mynet
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
  local HNAM HNUM HLIN
	if [ $# -eq 1 ]
	then
		HNAM=$1
    if 1isip "$HNAM"
    then
      echo "$HNAM"
      return 0
    fi
    if HLIN=$(cat $(find "$_1LIB" -name "*.hosts") | grep "$HNAM ")
    then
			for HIP in ${HLIN/$HNAM/}
			do
				if ping -c 1 "$HIP" > /dev/null
				then
					echo "$HIP"
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
					return 0
				fi
			done
    fi
		echo "$HNAM is unkown or unavailable."
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
      local HNAM=$(1host $1)
      _1verb "Trying to connect $HNAM ($1) with iperf"
      iperf -P 1 -i 5 -p "$_1IPERFPORT" -f M -t 60 -T 1 -c "$HNAM"
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
  local INFA
  if 1check tcpdump
  then
  	if [ "$#" == 1 ]
  	then
  		INFA=$1
  	else
  		INFA=$(ip address show | grep ^2: |  cut -f 2 -d :)
  	fi
  	tcpdump -c 100 -nv -i $INFA
  	return $?
  else
    return 1
  fi
}

# Check using ping if machine is online
# @param Machine name (optional). -q if you need a quiet mode
# @param URI or IP
function 1ison {
  local thename="$1"
  local thehost
  if [ $# -eq 2 ]
  then
    thehost=$(1host $2)
  else
    thehost=$(1host $1)
  fi
	if ping -q -c 1 -w 1 "$thehost" &> /dev/null
	then
		if [ $thename != "-q" ]
		then
			1tint 2 "$thename is active"
			echo
		fi
		return 0
	else
		if [ $thename != "-q" ]
		then
			1tint 1 "$thename not found"
			echo
		fi
		return 1
	fi
}

# Internal function, pre-1ssh
# @param server or user@server, to use with ssh
function _1pressh {
  local aux_u aux_h
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
}

# Access with SSH server (including extreme switchs)
# @param name or IP, or usr@IP
# @param Additional options for ssh
function 1ssh {
  local destip finalstatus
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
  fi
}

# Test open TCP ports [1-1500]
# @param IP (optional)
function 1ports {
  local aux CHECK
	local IP=${1:-127.0.0.1}
	local POPE=$(mktemp)
	local PREF=$(mktemp)
	if ! $(1ison -q $IP)
	then
		if aux=$(1hosts "$IP")
		then
			IP=$aux
		fi
	fi
	for p in {1..1500}
  do
		timeout 1 bash -c "(</dev/tcp/$IP/$p) &> /dev/null"
		CHECK=$?
		if [ $CHECK = 0 ]
		then
			echo "$p open" >> $POPE
			echo -n "#"
		else
			if [ $CHECK = 1 ]
			then
				echo "$p refused" >> $PREF
				echo -n "*"
			else
				echo -n "."
			fi
		fi
  done
	echo
	cat $PREF $POPE
	rm $PREF $POPE
}

# Return a possibly big string with all IP addresses in all interfaces
# @param (optional) Number of your interface. Default=all
function 1allhosts {
  if 1check ip ipcalc
  then
    local aux firstip lastip fp1 fp2 fp3 fp4 lp1 lp2 lp3 lp4 p1 p2 p3 p4 interfaces
    aux=$(1mynet)
    if [ $# -gt 0 ]
    then
      interfaces=$(echo $aux | cut -d\  -f $(1ajoin , $@))
    else
      interfaces=$aux
    fi
    _1verb Interfaces $interfaces
    for ether in $interfaces
    do
      aux=$(ipcalc $ether | grep HostM | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])')
      firstip=$(echo $aux | cut -d\  -f 1)
      lastip=$(echo $aux | cut -d\  -f 2)
      fp1=$(echo $firstip | cut -d. -f 1)
      fp2=$(echo $firstip | cut -d. -f 2)
      fp3=$(echo $firstip | cut -d. -f 3)
      fp4=$(echo $firstip | cut -d. -f 4)
      lp1=$(echo $lastip | cut -d. -f 1)
      lp2=$(echo $lastip | cut -d. -f 2)
      lp3=$(echo $lastip | cut -d. -f 3)
      lp4=$(echo $lastip | cut -d. -f 4)
      if [ $fp1 = $lp1 ]
      then
        p1=$fp1
      else
        p1="{$fp1..$lp1}"
      fi
      if [ $fp2 = $lp2 ]
      then
        p2=$fp2
      else
        p2="{$fp2..$lp2}"
      fi
      if [ $fp3 = $lp3 ]
      then
        p3=$fp3
      else
        p3="{$fp3..$lp3}"
      fi
      if [ $fp4 = $lp4 ]
      then
        p4=$fp4
      else
        p4="{$fp4..$lp4}"
      fi
      eval echo $p1.$p2.$p3.$p4
    done
  fi
}

# Return network(s) for all your interfaces
function 1mynet {
  if 1check ip
  then
    ip address | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])/(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | grep -v 127.0.0.1
  fi
}

# Scan on network for an given port
# @param Port to scan
function 1findport {
  if 1check ip ipcalc
  then
    local port
    local total=0
    if [ $# -eq 1 ]
    then
      port=$1
    else
      port=80
    fi
    for aux in $(1allhosts)
    do
      _1verb "trying $aux"
      timeout 1 bash -c "(</dev/tcp/$aux/$port) &> /dev/null"
      if [ $? = 0 ]
    	then
        total=$(($total+1))
    		echo "$aux:$port"
    	fi
    done
    _1verb "$total hosts with port $port open."
  fi
}
