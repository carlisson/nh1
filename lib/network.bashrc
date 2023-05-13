#!/bin/bash
# @file network.bashrc
# @brief Network utilities

_1NETLOCAL="$_1UDATA/network"
_1NETTIMEOUT=1 # timeout for pings and others
_1SERIALCOM="picocom minicom"
_1GETDIR="$HOME/Downloads"
_1GETQUEUE="$_1UDATA/download.queue"
_1IPERFPORT=2918

# @description Generate partial menu (for Network functions)
_nh1network.menu() {
  _1menuheader "$(_1text Network)"
  _1menuitem W 1allhosts "$(_1text "Returns all hosts in all your networks")" ip ipcalc
  _1menuitem W 1areon "$(_1text "Check status for every host in a internal .hosts")"
  _1menuitem W 1bauds "$(_1text "Returns baudrate for a number from 1 to 13")"
  _1menuitem W 1get "$(_1text "Start download(s)")" wget
  _1menuitem W 1getadd "$(_1text "Add URL to download later")"
  _1menuitem W 1getclear "$(_1text "Reset download queue")"
  _1menuitem W 1geticon "$(_1text "Download favicon from URL")"
  _1menuitem W 1getlist "$(_1text "List download planning")"
  _1menuitem W 1getdel "$(_1text "Delete URL from list to download")"
  _1menuitem W 1findport "$(_1text "Search in all network every IP with given port open")" ip ipcalc
  _1menuitem W 1host "$(_1text "Return a valid ping-available IP for some host or domain name")"
  _1menuitem W 1hostgroup "$(_1text "Lists all hosts in given group")"
  _1menuitem W 1hostset "$(_1text "Create or update a host entry")"
  _1menuitem W 1hostdel "$(_1text "Removes a host entry")"
  _1menuitem X 1hostimport "$(_1text "Imports hosts from DHCPD")"
  _1menuitem W 1hostmig "$(_1text "Migrates a host to another group")"
  _1menuitem W 1httpstatus "$(_1text "Return HTTP status for given URL")" curl
  _1menuitem W 1interfaces "$(_1text "List network interfaces")" ip
  _1menuitem X 1iperf "$(_1text "Run iperf connecting to a 1iperfd IP")" iperf
  _1menuitem X 1iperfd "$(_1text "Run iperfd, waiting for 1iperf connection")" iperf
  _1menuitem W 1isip "$(_1text "Return if a given string is an IP address")"
  _1menuitem W 1ison "$(_1text "Return if server is on. Params: (-q for quiet or name), IP")"
  _1menuitem W 1macvendor "$(_1text "Return prefixes for a given vendor")"
  _1menuitem W 1mynet "$(_1text "Return all networks running on network interfaces")" ip
  _1menuitem W 1ports "$(_1text "Scan if given port(s) for a given host is/are open")"
  _1menuitem W 1serial "$(_1text "Connect to a serial port")"
  _1menuitem W 1ssh "$(_1text "Connect a SSH server (working with eXtreme)")" ssh
  _1menuitem W 1tcpdump "$(_1text "Run tcpdump in a given network interface")" tcpdump
  _1menuitem W 1telnet "$(_1text "Connect a Telnet server")" telnet
  _1menuitem W 1xt-backup "$(_1text "Backup configuration of one or more extreme switchs")" ssh
  _1menuitem W 1xt-vlan "$(_1text "List all VLANs in given eXtreme switch")" ssh
  echo
}

# @description Clean variables
_nh1network.clean() {
  unset _1IPERFPORT _1NETLOCAL _1SERIALCOM _1NETTIMEOUT
  unset -f _nh1network.menu _nh1network.clean 1isip 1host 1iperf 1iperfd
  unset -f 1tcpdump 1ison _1pressh 1ssh 1ports 1findport 1allhosts
  unset -f 1mynet 1areon 1xt-vlan 1bauds 1serial 1macvendor 1httpstatus
  unset -f 1xt-backup _nh1network.init _nh1network.customvars _nh1network.info
  unset -f _nh1network.complete _nh1network.xt-backup 1telnet _1pretelnet
  unset -f _nh1network.smartssh _nh1network.ssh _nh1network.simplessh
  unset -f _nh1network.nossh 1hostgroup 1hostset 1hostdel 1hostmig
  unset -f _nh1network.complete.hostvar _nh1network.complete.hostmig
  unset -f 1interfaces 1get 1getadd 1getlist 1getdel _1network.download
  unset -f 1getclear 1geticon 1hostimport
}

# @description Autocompletion for 1hostget and 1hostget
_nh1network.complete.hostvar() {
	local _ARG
  	COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
		COMPREPLY=($(_1list $_1NETLOCAL "hosts"))
	elif [ "$COMP_CWORD" -eq 2 ]
	then
		_ARG=("${COMP_WORDS[1]}");
		COMPREPLY=($(_1db.show "$_1NETLOCAL" "hosts" "$_ARG" "list"))
  fi
}

# @description Autocompletion for 1hostmig
_nh1network.complete.hostmig() {
	local _ARG
  	COMREPLY=()
    case "$COMP_CWORD" in
      1|3)
    		COMPREPLY=($(_1list $_1NETLOCAL "hosts"))
        ;;
      2) 
    		_ARG=("${COMP_WORDS[1]}");
    		COMPREPLY=($(_1db.show "$_1NETLOCAL" "hosts" "$_ARG" "list"))
        ;;
	esac
}

# @description Auto-completion
_nh1network.complete() {
  complete -W "$(_1list $_1NETLOCAL "hosts")" 1areon
  complete -W "$(_1list $_1NETLOCAL "hosts")" 1hostgroup
  complete -W "$(seq 1 13)" 1bauds
  complete -W "$(1interfaces)" 1tcpdump
  complete -F _nh1network.complete.hostvar 1hostset 1hostdel
  complete -F _nh1network.complete.hostmig 1hostmig
}

# @description Initial commands
_nh1network.init() {
  mkdir -p "$_1NETLOCAL"
  mkdir -p "$_1GETDIR"
  touch "$_1GETQUEUE"
}

# @description Load variables defined by user
_nh1network.customvars() {
  _1customvar NORG_NETWORK_DIR _1NETLOCAL
  _1customvar NORG_NETWORK_TIMEOUT _1NETTIMEOUT number
  _1customvar NORG_IPERF_PORT _1IPERFPORT number
  _1customvar NORG_DOWNLOAD_DIR _1GETDIR
}

# @description Information about custom vars
_nh1network.info() {
  _1menuitem W NORG_NETWORK_DIR "$(_1text "Path for network (hosts and groups) files.")"
  _1menuitem W NORG_NETWORK_TIMEOUT "$(_1text "Timeout for check functions.")"
  _1menuitem W NORG_IPERF_PORT "$(printf "$(_1text "Server port. Default: %s.")" "2918")"
  _1menuitem W NORG_DOWNLOAD_DIR "$(_1text "Path where save downloads when using 1get.")"
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1network.usage() {
  case $1 in
    geticon)
        printf "$(_1text "Usage: %s <%s> <%s>")\n" "1$1" "$(_1text "URL")" "$(_1text "Output file")"
        ;;
    hostimport)
        printf "$(_1text "Usage: %s %s")\n" "1$1" "$(_1text "New host group name")"
        ;;
    *)
      false
      ;;
  esac
}

# Alias like

# @description Get HTTP status for given URL
# @arg $1 string URL
# @stdout Code for HTTP status
1httpstatus() {
  curl --max-time $_1NETTIMEOUT --write-out "%{http_code}\n" --silent --output /dev/null "$1"
}

# @description Returns baudrate for given number
# @arg $1 int Number of baudrate in interval 1-13
# @stdout Real baudrate equivalent to given number
1bauds() {
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
    _1text "Bauds possible:"
    echo
    for i in $(seq 1 13)
    do
      1tint "$i"
      echo -n "  "
      1bauds $i
    done
  fi
}

# @description Check if a string is an IP address
# @arg $1 string Value to test if is an IP
# @exitcode 0 Confirm $1 is IP
# @exitcode 1 It's not an IP address
1isip() {
  if [ $# -eq 1 ]
  then
    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
    then
      return 0
    else
      return 1
    fi
  else
    _1text "You need to give a string to test if it is an IP address."
  fi
}

# @description Check files .hosts in lib/local and lib/remote, for a name, returning a valid IP
# @arg $1 string Host name you need an IP
# @stdout IP address correspondent to given hostname
# @exitcode 0 1host works fine
# @exitcode 1 Unknown or unaccessible host
1host() {
  local HNAM HNUM HLIN
  if [ $# -eq 1 ]
  then
    HNAM=$1
    if 1isip "$HNAM"
    then
      echo "$HNAM"
      return 0
    fi
    if HLIN=$(cat $(find "$_1NETLOCAL/" -name "*.hosts") | grep "$HNAM=")
    then
      for HIP in ${HLIN/$HNAM=/}
      do
        if ping -c 1 -w $_1NETTIMEOUT "$HIP" > /dev/null
        then
          echo "$HIP"
          return 0
        fi
      done
    fi
    if 1check -s dig
    then
      if HLIN=$(dig +short "$HNAM" | xargs)
      then
        for HIP in ${HLIN/$HNAM/}
        do
          echo "$HIP"
        done
      fi
    else
      echo "$HNAM"
      return 2
    fi
    printf "$(_1text "%s is unkown or unavailable.")\n" $HNAM
    return 1
  else
    _1text "You need to put a machine name"
  fi
}

# @description Lists all hosts in given group
# @arg $1 string Command: list, new or del (optional. Default: list)
# @arg $2 string Group name
1hostgroup() {
	_1before
  local COMM GRP
  case $# in
    1)
      COMM="list"
      GRP="$1"
      ;;
    2)
      COMM="$1"
      GRP="$2"
      ;;
    *)
      COMM="unknown"
      ;;
  esac

  case $COMM in
    list)
      _1db.show "$_1NETLOCAL" "hosts" "$GRP"
      return $?
      ;;
    new)
      _1db "$_1NETLOCAL" "hosts" new "$GRP"
      return $?
      ;;
    del)
      _1db "$_1NETLOCAL" "hosts" del "$GRP"
      return $?
      ;;
    *)
      _1text "Usage:"
      echo "1hostgroup [group-name]"
      echo "1hostgroup (new|del) [group-name]"
		  echo "$(_1text "Available groups"): "$(_1list "$_1NETLOCAL" "hosts")
      ;;
  esac
}

# @description Create or update a host entry
# @arg $1 string Group name
# @arg $2 string Host name
# @arg $3 string Host IP or IPs
1hostset() {
	_1before
  local GRP HNM
  if [ $# -lt 3 ]
  then
    _1text "Usage:"
    echo "1hostset <group> <name> [<ips>]"
  else
    GRP="$1"
    HNM="$2"
    shift 2
    _1db.set "$_1NETLOCAL" "hosts" "$GRP" "$HNM" "$*"
    return $?
  fi
}

# @description Removes a host entry
# @arg $1 string Group name
# @arg $2 string Host name
1hostdel() {
	_1before
  local GRP HNM
  if [ $# -ne 2 ]
  then
    _1text "Usage:"
    echo "1hostdel <group> <name>"
  else
    _1db.set "$_1NETLOCAL" "hosts" "$1" "$2"
    return $?
  fi
}

# @description Migrates a host to another group
# @arg $1 string Actual group name
# @arg $2 string Host name
# @arg $3 string New group name
# @exitcode 0 It works
# @exitcode 1 Variable not found
# @exitcode 2 Insertion fails
1hostmig() {
	_1before
  local HVAL
  if [ $# -eq 3 ]
  then
    HVAL=$(_1db.get "$_1NETLOCAL" "hosts" "$1" "$2")
    if [ $? -eq 0 ]
    then
      1hostdel "$1" "$2"
      1hostset "$3" "$2" "$HVAL"
      if [ $? -gt 0 ]
      then
        1hostset "$1" "$2" "$HVAL"
        return 2
      fi
    else
      _1text "Host or group not found."
      echo
      return 1
    fi
  else
    printf "$(_1text "Usage: %s.")\n" "1hostmig [group] [host] [new-group]"
  fi
  return 0
}

# @description Run iperf with a simple and functional configuration, connecting iperfd IP
# @arg $1 string IP of a machine running 1iperfd
# @see 1iperfd
1iperf() {
  if 1check iperf
  then
    if [ $# -eq 1 ]
    then
      local HNAM=$(1host $1)
      _1verb "$(printf "$(_1text "Trying to connect %s (%s) with iperf.")\n" $HNAM $1)"
      iperf -P 1 -i 5 -p "$_1IPERFPORT" -f M -t 60 -T 1 -c "$HNAM"
    else
      _1text "You need to put a IP address where 1iperfd is running."
    fi
  fi
}

# @description Run iperf with a simple and functional configuration, as daemon, wainting connection
# @see 1iperf
1iperfd() {
  if 1check iperf
  then
    iperf -s -P 2 -i 5 -p "$_1IPERFPORT" -f M
  fi
}

# @description Run tcpdump with a simple and functional configuration
# @arg $1 string Interface to listen
# @exitcode 0 tcpdump works
# @exitcode 1 tcpdump not found
1tcpdump() {
	_1before
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

# @description Check using ping if machine is online
# @arg $1 string Machine name (optional). -q if you need a quiet mode
# @arg $2 string URI or IP
# @exitcode 0 Machine is on
# @exitcode 1 Machine not accessible
1ison() {
  local thename="$1"
  local thehost
  if [ $# -eq 2 ]
  then
    thehost=$(1host $2)
  else
    thehost=$(1host $1)
  fi
  if ping -q -c 1 -w $_1NETTIMEOUT "$thehost" &> /dev/null
	then
		if [ $thename != "-q" ]
		then
      _1verb "$(printf "$(_1text "IP %s returned for machine %s.")" "$thehost" "$thename")"
			1tint 2 "$(printf "$(_1text "%s is active")" $thename)"
			echo
		fi
		return 0
	else
		if [ $thename != "-q" ]
		then
			1tint 1 "$(printf "$(_1text "%s not found")" $thename)"
			echo
		fi
		return 1
	fi
}

# @description Internal function, pre-1ssh
# @arg $1 string server or user@server, to use with ssh
# @stdout user@machine, to use as argument for 1ssh
# @see 1ssh
_1pressh() {
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

# @description Internal function, pre-1telnet
# @arg $1 string server or user@server
# @stdout arguments for use with telnet
# @see 1telnet
_1pretelnet() {
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
	echo "$aux_h"
}

# @description What to do when SSH port is closed
# @arg $1 string IP
_nh1network.nossh() {
  local onlyip
  onlyip="$1"
  if 1ports "$onlyip" 23 > /dev/null
  then
    _1text "SSH is not available. Trying to connect via Telnet."
    1telnet $onlyip
  else
    if 1ports "$onlyip" 443 > /dev/null
    then
      printf "$(_1text "Telnet is not available. You can access this IP in your browser: %s://%s.")\n" "https" "$onlyip"
    elif 1ports "$onlyip" 80 > /dev/null
    then
      printf "$(_1text "Telnet is not available. You can access this IP in your browser: %s://%s.")\n" "http" "$onlyip"
    else
      printf "$(_1text "Cannot connect %s.")\n" "$onlyip"
    fi
  fi

}

# @description SSH discovery using nmap
# @arg $1 string name or IP, or usr@IP
# @arg $2 string Additional options for ssh
_nh1network.smartssh() {
  local  line next comm aux SAVEIFS pressh args thiskey
  if 1check nmap
  then
    onlyip=$(_1pretelnet $1)
    next=""
    comm="ssh "
    args="$2"
    pressh="$(_1pressh $1)"

    if 1ports "$onlyip" 22 > /dev/null
    then

      SAVEIFS=$IFS
      IFS=$(echo -en "\n\b")
      for line in $(nmap --script ssh2-enum-algos -sV -p 22 "$onlyip")
      do
        if [ -n "$next" ]
        then
          thiskey="$(echo $line | tr -d '[:space:]' | tr -d '|')"
          comm="$comm $next$thiskey"
          if [ "$next" = "-oHostKeyAlgorithms=+" ]
          then
            comm="$comm -oPubkeyAcceptedAlgorithms=+$thiskey"
          fi
          next=""
        fi
        if $(echo $line | grep -q kex_algorithms)
        then
          next="-oKexAlgorithms=+"
        elif $(echo $line | grep -q server_host_key_algorithms)
        then
          next="-oHostKeyAlgorithms=+"
        elif $(echo $line | grep -q encryption_algorithms)
        then
          next="-c "
        fi
      done
      IFS=$SAVEIFS
      _1verb "$comm $pressh $args"
      $comm "$pressh" $args
    else
      _nh1network.nossh "$onlyip"
    fi
    return 0
  else
    return 1
  fi
}

# @description Connetc SSH server with specified protocol
# @arg $1 string name or IP, or usr@IP
# @arg $2 Host-key algorithm
# @arg $3 Cipher algorithm
# @arg $4 string Additional options for ssh
_nh1network.ssh() {
  local destin hostkey ciph comm pre
  destin="$1"
  hostkey="$2"
  ciph="$3"
  comm="$4"
  pre=" "
  case $hostkey in
    ssh-dss)
      pre="-oKexAlgorithms=+diffie-hellman-group1-sha1"
      ;;
  esac
  _1verb "$(printf "$(_1text "Trying to connect using cipher %s and host-key %s")" "$ciph" "$hostkey")"
  ssh -c "$ciph" $pre -oHostKeyAlgorithms=+$hostkey "$destin" $comm
  return $?
}

# @description Access with SSH server (including extreme switchs)
# @arg $1 string name or IP, or usr@IP
# @arg $2 string Additional options for ssh
_nh1network.simplessh() {
  local destip finalstatus onlyip
  if 1check ssh
  then
    _1verb "$(printf "$(_1text "Connecting via %s.")" "ssh")"
  	destip=$(_1pressh $1)
    onlyip=$(_1pretelnet $1)
    finalstatus=1

  	# If one method don't works, 1ssh try next
    if 1ports "$onlyip" 22 > /dev/null
    then
      _1verb "$(_1text "Trying connect in simple mode")"
      ssh "$destip" $2
      finalstatus=$?
      if [ $finalstatus -gt 0 ]
      then
        _nh1network.ssh $destip rsa-sha2-256 aes192-cbc "$2"
        finalstatus=$?
        if [ $finalstatus -gt 0 ]
        then
          _nh1network.ssh $destip ssh-dss aes192-cbc "$2"
          finalstatus=$?
          if [ $finalstatus -gt 0 ]
          then
            _nh1network.ssh $destip ssh-rsa aes256-ctr "$2"
            finalstatus=$?
          fi
        fi
      fi

      if [ $finalstatus -eq 0 ]
      then
        _1verb "$(_1text "It works.")"
      else
        printf "$(_1text "Cannot connect with %s using SSH.")\n" $1
      fi
    else
      _nh1network.nossh "$onlyip"
    fi
  fi
}

# @description Try to use smart ssh. If it don't works, use simplessh
# @arg $1 string name or IP
# @arg $1 string name or IP, or usr@IP
# @arg $2 string Additional options for ssh
1ssh() {
	_1before
  _nh1network.smartssh "$1" "$2" "$3"
  if [ $? -gt 0 ]
  then
    _nh1network.simplessh "$1" "$2" "$3"
  fi
}

# @description Access with telnet server
# @arg $1 string name or IP, or usr@IP
# @arg $2 string Additional options for telnet
1telnet() {
	_1before
  local destip finalstatus
  if 1check telnet
  then
    _1verb "$(printf "$(_1text "Connecting via %s.")" "telnet")"
    destip=$(_1pretelnet $1)
    finalstatus=1
    telnet $destip $2
  fi
}

# @description Test open TCP ports
# @arg $1 string IP
# @arg $2 int Port (or ports). Optional. Default: 1-1500
1ports() {
	if [ $# -gt 0 ]
  then
    local aux CHECK
    local IP="$(1host $1)"; shift
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
          _1verb "$(printf "$(_1text "%s is on")" $p)"
      		if aux=$(1host "$p")
      		then
      			IP=$aux
          else
            _1verb "$(_1text "Host not found.")"
            return 1
      		fi
      	fi
      else
    		timeout $_1NETTIMEOUT bash -c "(</dev/tcp/$IP/$p) &> /dev/null"
    		CHECK=$?
    		if [ $CHECK = 0 ]
    		then
    			printf "$(_1text "%s open")\n" $p >> $POPE
    			echo -n "#"
    		else
    			if [ $CHECK = 1 ]
    			then
    				printf "$(_1text "%s refused")\n" $p >> $PREF
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

# @description Return a possibly big string with all IP addresses in all interfaces
# @arg $1 int (optional) Number of your interface. Default=all
# @stdout All IP address in network inteface(s)
1allhosts() {
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

# @description Return network(s) for all your interfaces
# @stdout Network addresses for all interfaces
1mynet() {
  if 1check ip
  then
    ip address | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])/(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | grep -v 127.0.0.1
  fi
}

# @description Scan on network for an given port
# @arg $1 int Port to scan
1findport() {
	_1before
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
      _1verb "$(printf "$(_1text "trying %s:%s")" $aux $port)"
      1ports "$aux" "$port" &> /dev/null
      if [ $? = 0 ]
    	then
        total=$(($total+1))
    		echo "$aux:$port"
    	fi
    done
    _1verb "$(printf "$(_1text "%i hosts with port %i open.")\n" $total $port)"
  fi
}

# @description Check status for every host in given .hosts
# @arg $1 string set of hosts
1areon() {
	_1before
    local FILE TOTAL HLIN HNAM OK AUX
    _nh1network.init
  	if [ $# -ne 1 ]
	then
		echo -n "Usage: "
		1tint 2 "1areon [$(_1text "group")]"
		echo
		echo
		echo "  all: $(_1text "every host in all groups")"
		echo
		echo "$(_1text "Available groups"): "$(_1list "$_1NETLOCAL" "hosts")
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
			HNAM=$(echo $HLIN | cut -f 1 -d "=")
			OK=1
			for HIP in ${HLIN/$HNAM=/}
			do
        if [ $OK -eq 1 ]
				then
					AUX=$(1ison $HNAM $HIP)
					OK=$?
				fi
			done
      echo $AUX
		done
		return 0
	else
		_1text "Unknown group of hosts."
		return 1
	fi
}

# @description List VLANs in given switch
# @arg $1 string IP or name (.hosts) for one or more switchs
1xt-vlan() {
	_1before
    local AUX usrhst
	if [ $# -eq 0 ]
	then
		echo -n "Usage: "
		1tint 2 '1xt-vlan <IP> (<IP> ...)'
		echo
		_1text "You can use hostnames contained in .hosts"
		return 1
	fi
	for AUX in "$@"
	do
		echo
		echo ">>> $AUX"
		usrhst=$(_1pressh $AUX)
		printf " $(_1text "VLANs in SWITCH! Please inform password for %s.")\n" $usrhst
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

# @description Connect a serial port with appropriated program
# @arg $1 int Bauds in 1bauds or traditional scale
1serial() {
	_1before
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
    echo -n "$(_1text "Serial program not found. Checked")"
    1tint 2 $_1SERIALCOM
    echo
    return 1
  else
    _TTY=$(ls /dev/ttyU*)

    if [ $_TTY ]
    then
      _1sudo $_COM -b $_BAU $_ADJ $_TTY
    else
      _1text "No ttyUSB found."
      return 2
    fi
  fi
}

# @description Return MAC prefixes for a given vendor
# @arg $1 string Vendor
# @stdout MAC prefixes
1macvendor() {
	_1before
  if [ $# -eq 1 ]
  then
    grep -i "$1" "$_1LIB/mac-vendors.txt"  | sed 's/\(..\)/\1:/g' | cut -c 1-9 | tr '[:upper:]' '[:lower:]'
  else
    echo -n "Usage: "
    1tint 2 '1macvendor <Company>'
    echo
  fi
}

# @description Do a single extreme switch backup
# @arg $1 string Switch by extreme
# @arg $2 string Filename
_nh1network.xt-backup() {
  _1verb "$(printf "$(_1text "Doing backup of %s to %s")" $1 $2)"
	1ssh "$1" "show configuration" > "$2"
	wc $2
}

# @description Backup from one or more switchs extreme
# @arg $1 string host or group
1xt-backup() {
	_1before
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

# @description List network interfaces, excluding loopback
1interfaces() {
	_1before
    ip a | grep "^[[:digit:]]" | cut -d\: -f 2 | grep -v lo | xargs
}

# @description Do download of given URL
# @arg $1 string URL to download
# @exitcode 0 Download ok
# @exitcode 1 Error
_1network.download() {
  local _TARGET _STATUS
  _TARGET="$1"
  pushd "$_1GETDIR" > /dev/null
  _1message "$(printf "$(_1text "Downloading %s")" "$_TARGET")"
  wget -c -nv --show-progress "$_TARGET"
  _STATUS=$?
  popd > /dev/null
  return $_STATUS
}

# @description Start a download and/or the download list
# @arg $1 string URL to download (optional)
1get() {
  _1before
  local _TMP _IFS _LIN _STA
  if ! 1check wget
  then
    return 1
  fi
  if [ $# -eq 0 -a ! -s "$_GETQUEUE" ]
  then
    printf "$(_1text "Usage: 1get [%s]")\n" "URL"
    _1text "URL is optional. 1get starts download of every URL in queue."
    echo
  fi
  _TMP="$(mktemp)"
  while [ $# -gt 0 ]
  do
    cp "$_1GETQUEUE" "$_TMP"
    echo "$1" > "$_1GETQUEUE"
    cat "$_TMP" >> "$_1GETQUEUE"
    shift
  done
  cp "$_1GETQUEUE" "$_TMP"

  _IFS=$IFS
  IFS=$(echo -en "\n\b")
  for _LIN in $(cat "$_TMP")
  do
    _STA=0
    while [ $_STA -lt 3 ]
    do
      _1network.download "$_LIN"
      if [ $? -eq 0 ]
      then
        _STA=100
      else
        _STA=$((_STA+1))
      fi
    done
    case $_STA in
      100)
        _1verb "$(printf "$(_1text "Download of %s successful.")\n" "$_LIN")"
        1getdel "$_LIN"
        ;;
      3)
        _1message error "$(printf "$(_1text "Error downloading %s.")" "$_LIN")"
        ;;
    esac
  done
  IFS=$_IFS
  rm "$_TMP"
  return 0
}

# @description Add a URL to download list
# @arg $1 string URL to download
1getadd() {
  local _URL
  if [ $# -gt 0 ]
  then
    for _URL in $*
    do
      echo "$_URL" >> "$_1GETQUEUE"
    done
  else
    printf "$(_1text "Usage: %s [%s]")\n" "1getadd" "URL(s)"
  fi
}

# @description Reset download queue
1getclear () {
  rm "$_1GETQUEUE"
  touch "$_1GETQUEUE"
}

# @description List download queue
1getlist() {
  _1before
  1banner "$(_1text "Download Queue")"
  if [ -s "$_1GETQUEUE" ]
  then
    cat "$_1GETQUEUE"
  else
    _1message "$(_1text "Download queue is empty.")"
  fi
}

# @description Delete an item from download queue
# @arg $1 string URL to remove from download list
1getdel() {
  local _TMP
  if [ $# -eq 1 ]
  then
    _TMP="$(mktemp)"
    cp "$_1GETQUEUE" "$_TMP"
    grep -hv "^$1$" "$_TMP" > "$_1GETQUEUE"
    rm "$_TMP"
  else
    printf "$(_1text "Usage: %s [%s]")\n" "1getdel" "URL"
  fi
}

# @description Get favicon from given URL
# @arg $1 string URL
# @arg $2 string Output file
1geticon() {
  if [ $# -ne 2 ]
  then
    _nh1network.usage geticon
    return 2
  fi
  local _URL="$1"
  local _FILE="$2"
  #local _FAV="$(curl --silent -L "$_URL" | tr '\n' ' ' | sed 's/[''"]//g' | sed 's/\(.*\)=\([^=\<\>]*\.\(ico|png\)\)\(.*\)/\2/g')"
  local _FAV="$(curl --silent -L "$_URL" | tr '\n' ' ' | tr '<' '\n' | tr '>' ' ' | grep favicon |  sed 's/[''"]//g' | sed 's/\(.*\)href=\([^=\<\> ]*\)\(.*\)/\2/g' | head -n 1)"
  echo "FAV: $_FAV"
  if [[ "$_FAV" =~ [\<\>\!] ]] || [ -z "$_FAV" ]
  then
    return 1
  fi
  if ! [[ "$_FAV" =~ ^http ]]
  then
    if [[ "$_FAV" =~ ^\/ ]]
    then
      _FAV="$(echo "$_URL" | sed 's/\(http\(s*\):\/\/\([^/]*\)\)\(.*\)/\1/')$_FAV"
    else
      _FAV="$_URL/$_FAV"
    fi
  fi
  if [[ "$_FAV" =~ \.ico$ ]]
  then
    curl --silent -o "$_FILE" -L "$_FAV"
  else
    local _TMP="$(mktemp).ico"
    curl --silent -o "$_TMP" -L "$_FAV"
    convert "$_TMP" "$_FILE"
  fi
}

# @description Imports hosts from dhcpd.conf
# @arg $1 string Hostgroup name
1hostimport() {
  if [ $# -eq 1 ]
  then
    if [ ! -f "$_1NETLOCAL/$1.hosts" ]
    then
      if [ -f "/etc/dhcp/dhcpd.conf" ]
      then
        cat "/etc/dhcp/dhcpd.conf" | tr '\n' ' ' | sed "s/host /\n/g" | grep fixed | sed "s/\([^a-zA-Z]*\)\([A-Za-z]\+\){\(.*\)172\([^;]*\)\(.*\)/\2=172\4/g" > $_NETLOCAL/$1.hosts
        if [ $? -eq 0 ]
        then
          return 0
        else
          return 3
        fi
      else
        _1message error "$(_1text "DHCPD file not found. Are you in a network server?")"
        return 2
      fi
    else
      _1message error "$(printf "$(_1text "A network group with name %s already exists.")" "$1")"
      return 1
    fi
  else
    network.usage hostimport
    return 0
  fi
}