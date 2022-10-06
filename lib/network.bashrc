#!/bin/bash

_1NETLOCAL="$_1UDATA/network"
_1SERIALCOM="picocom minicom"
_1IPERFPORT=2918

# Generate partial menu (for Network functions)
function _nh1network.menu {
  echo "___ Network ___"
  _1menuitem X 1allhosts "Returns all hosts in all your networks" ip ipcalc
  _1menuitem X 1areon "Check status for every host in a internal .hosts"
  _1menuitem X 1bauds "Returns baudrate for a number from 1 to 13"
  _1menuitem X 1findport "Search in all network every IP with given port open" ip ipcalc
  _1menuitem W 1host "Return a valid ping-available IP for some host or domain name"
  _1menuitem X 1httpstatus "Return HTTP status for given URL" curl
  _1menuitem X 1iperf "Run iperf connecting to a 1iperfd IP" iperf
  _1menuitem X 1iperfd "Run iperfd, waiting for 1iperf connection" iperf
  _1menuitem X 1isip "Return if a given string is an IP address"
  _1menuitem X 1ison "Return if server is on. Params: (-q for quiet or name), IP"
  _1menuitem X 1macvendor "Return prefixes for a given vendor"
  _1menuitem X 1mynet "Return all networks running on network interfaces" ip
  _1menuitem X 1ports "Scan if given port(s) for a given host is/are open"
  _1menuitem X 1serial "Connect to a serial port"
  _1menuitem X 1ssh "Connect a SSH server (working with eXtreme)" ssh
  _1menuitem X 1tcpdump "Run tcpdump in a given network interface" tcpdump
  _1menuitem X 1xt-backup "Backup configuration of one or more extreme switchs" ssh
  _1menuitem X 1xt-vlan "List all VLANs in given eXtreme switch" ssh
  echo
}

# Clean variables
function _nh1network.clean {
  unset _1IPERFPORT
  unset -f _nh1network.menu _nh1network.clean 1isip 1host 1iperf 1iperfd
  unset -f 1tcpdump 1ison _1pressh 1ssh 1ports 1findport 1allhosts
  unset -f 1mynet 1areon 1xt-vlan 1bauds 1serial 1macvendor 1httpstatus
  unset -f 1xt-backup _nh1network.init
}

function _nh1network.complete {
  complete -W "$(_1list $_1NETLOCAL "hosts")" 1areon
  complete -W "$(seq 1 13)" 1bauds
}

function _nh1network.init {
  mkdir -p "$_1NETLOCAL"
}

# Alias like
function 1httpstatus { curl --write-out "%{http_code}\n" --silent --output /dev/null ; }

# Returns baudrate for given number
# @param Number of baudrate
function 1bauds {
  if [ $# -eq 1 ]
  then
    case $1 in
      1)  echo    300 ;;
      2)  echo    600 ;;
      3)  echo   1200 ;;
      4)  echo   1800 ;;
      5)  echo   2400 ;;
      6)  echo   4800 ;;
      7)  echo   9600 ;;
      8)  echo  19200 ;;
      9)  echo  28800 ;;
      10) echo  38400 ;;
      11) echo  57600 ;;
      12) echo  76800 ;;
      13) echo 115200 ;;
    esac
  else
    echo "Bauds possible:"
    echo
    for i in $(seq 1 13)
    do
      1tint "$i"
      echo -n "  "
      1bauds $i
    done
  fi
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
    if HLIN=$(cat $(find "$_1NETLOCAL/" -name "*.hosts") | grep "$HNAM ")
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
  local aux_u aux_h aux
	if [ $(echo "$1" | grep "@") ]
	then
		aux_u=${1%@*}
		aux_h=${1#*@}
	else
		aux_u="admin"
		aux_h="$1"
	fi
    if aux=$(1host "$aux_h")
	then
		aux_h=$aux
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

# Test open TCP ports
# @param IP
# @param (optional). Port (or ports). Default: 1-1500
function 1ports {
  if [ $# -gt 0 ]
  then
    local aux CHECK
    local IP="$1"; shift
  	local POPE=$(mktemp)
  	local PREF=$(mktemp)
    local PMOD=0 # 1ports mode. 0 - multiple; 1 - single
    local PTC #Ports To Check
    if [ $# -eq 0 ]
    then
      PTC=$(echo eval {1..1500})
    else
      PTC=$@
    fi
    if [ $# -eq 1 ]
    then
      PMOD=1
    fi
  	for p in $PTC
    do
      if [ "$IP" = "NONE" ]
      then
        _1verb $p
        if $(1ison -q $p)
      	then
          _1verb "$p is on"
      		if aux=$(1host "$p")
      		then
      			IP=$aux
          else
            _1verb "Host not found."
            return 1
      		fi
      	fi
      else
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
      fi
    done
    cat $PREF $POPE
  	if [ $PMOD = 1 ]
    then
      return $CHECK
    fi
  	rm $PREF $POPE
  fi
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
      1ports "$aux" "$port" &> /dev/null
      if [ $? = 0 ]
    	then
        total=$(($total+1))
    		echo "$aux:$port"
    	fi
    done
    _1verb "$total hosts with port $port open."
  fi
}

# Check status for every host in given .hosts
# @param set of hosts
function 1areon {
    local FILE TOTAL HLIN HNAM OK
    _nh1network.init
  	if [ $# -ne 1 ]
	then
		echo -n "Usage: "
		1tint 2 '1areon [group]'
		echo
		echo
		echo "  all: every host in all groups"
		echo
		echo "Available groups: "$(_1list $_1NETLOCAL "hosts")
		return 1
	fi
	if [ "$1" = "all" ]
	then
		FILE=$(mktemp)
		cat $(find "$_1NETLOCAL/" -name "*.hosts") > $FILE
	else
		FILE="$_1NETLOCAL/$1.hosts"
	fi
	if [ -f "$FILE" ]
	then
		TOTAL=$(wc -l < "$FILE")
		for line in $(seq 1 $TOTAL)
		do
			HLIN=$(sed -n "$line"p < "$FILE")
			HNAM=$(echo $HLIN | cut -f 1 -d " ")
			OK=1
			for HIP in ${HLIN/$HNAM/}
			do
				if [ $OK -eq 1 ]
				then
					1ison $HNAM $HIP
					OK=0
				fi
			done
		done
		return 0
	else
		echo "Unknown group of hosts."
		return 1
	fi
}

# List VLANs in given switch
# @param IP or name (.hosts) for one or more switchs
function 1xt-vlan {
    local AUX usrhst
	if [ $# -eq 0 ]
	then
		echo -n "Usage: "
		1tint 2 '1xt-vlan <IP> (<IP> ...)'
		echo
		echo "You can use hostnames contained in .hosts"
		return 1
	fi
	for AUX in "$@"
	do
		echo
		echo ">>> $AUX"
		usrhst=$(_1pressh $AUX)
		echo " VLANs in SWITCH! Please inform password for $usrhst"
		1ssh "$usrhst" "show vlan detail" | grep -v \( | grep -v 'Description:' | grep -E 'VLAN|,|ag:| Tag ' | sed '
			s/VLAN\ Interface\ with\ name/nNnVLAN/g
			s/\ created\ by user/:/g
			s/[ ^I][ ^I]*/ /g
			s/.*Tag //g' | tr -d '\r' | tr -d '\n' | sed '
			s/\(VLAN\|Tag\|Untag\)/\n&/g
			s/nNn/\n/g'
		echo
	done
}

# Connect a serial port with appropriated program
# @param Bauds in 1bauds or traditional scale
function 1serial {
  local _BAU _COM _AUX _TTY _ADJ

  if [ $# -eq 1 ]
  then
    if [ $1 -lt 14 ]
    then
      _BAU=$(1bauds $1)
    else
      _BAU=$1
    fi
  else
    _BAU=9600
  fi

  _COM=""
  _ADJ=""
  for _AUX in $_1SERIALCOM
  do
    if [ -z "$_COM" ]
    then
      if 1check $_AUX
      then
        _COM="$_AUX"
        if [ "$_AUX" = "minicom" ]
        then
          _ADJ="-D"
        fi
      fi
    fi
  done

  if [ -z "$_COM" ]
  then
    echo -n "Serial program not found. Checked"
    1tint 2 $_1SERIALCOM
    echo
    return 1
  else
    _TTY=$(ls /dev/ttyU*)

    if [ $_TTY ]
    then
      _1sudo $_COM -b $_BAU $_ADJ $_TTY
    else
      "No ttyUSB found."
      return 2
    fi
  fi
}

# Return MAC prefixes for a given vendor
# @param Vendor
function 1macvendor {
  if [ $# -eq 1 ]
  then
    grep -i "$1" "$_1LIB/mac-vendors.txt"  | sed 's/\(..\)/\1:/g' | cut -c 1-9 | tr '[:upper:]' '[:lower:]'
  else
    echo -n "Usage: "
    1tint 2 '1macvendor <Company>'
    echo
  fi
}

# Do a single extreme switch backup
# @param Switch by extreme
# @param Filename
function _nh1network.xt-backup {
  _1verb "Doing backup of $1 to $2"
	1ssh "$1" "show configuration" > "$2"
	wc $2
}

# Backup from one or more switchs extreme
# @param host or group
function 1xt-backup {
  local _HOST _SUF _H
  _SUF="$(date +%Y-%m-%d).extreme"
  for _HOST in $@
  do
    if 1host $_HOST > /dev/null
    then
      _nh1network.xt-backup $_HOST "$_HOST.$_SUF"
    elif [ -f "$_1NETLOCAL/$_HOST.hosts" ]
    then
      for _H in $(1areon $_HOST | grep -v 'not' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[bmGK]//g" | sed 's/\\033\\(b is active//g')
      do
	      if [[ $_H =~ ^x ]]
	      then
          _nh1network.xt-backup "$_H" "$_H.$_SUF"
      	fi
      done
    fi
  done
}
