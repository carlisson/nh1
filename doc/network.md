# network.bashrc

Network utilities

## Overview

Generate partial menu (for Network functions)

## Index

* [_nh1network.menu](#_nh1networkmenu)
* [_nh1network.clean](#_nh1networkclean)
* [_nh1network.complete](#_nh1networkcomplete)
* [_nh1network.init](#_nh1networkinit)
* [_nh1network.customvars](#_nh1networkcustomvars)
* [_nh1network.info](#_nh1networkinfo)
* [1httpstatus](#1httpstatus)
* [1bauds](#1bauds)
* [1isip](#1isip)
* [1host](#1host)
* [1iperf](#1iperf)
* [1iperfd](#1iperfd)
* [1tcpdump](#1tcpdump)
* [1ison](#1ison)
* [_1pressh](#_1pressh)
* [1ssh](#1ssh)
* [1ports](#1ports)
* [1allhosts](#1allhosts)
* [1mynet](#1mynet)
* [1findport](#1findport)
* [1areon](#1areon)
* [1xt-vlan](#1xt-vlan)
* [1serial](#1serial)
* [1macvendor](#1macvendor)
* [_nh1network.xt-backup](#_nh1networkxt-backup)
* [1xt-backup](#1xt-backup)

### _nh1network.menu

Generate partial menu (for Network functions)

### _nh1network.clean

Clean variables

### _nh1network.complete

Auto-completion

### _nh1network.init

Initial commands

### _nh1network.customvars

Load variables defined by user

### _nh1network.info

Information about custom vars

### 1httpstatus

Get HTTP status for given URL

#### Arguments

* **$1** (string): URL

#### Output on stdout

* Code for HTTP status

### 1bauds

Returns baudrate for given number

#### Arguments

* **$1** (int): Number of baudrate in interval 1-13

#### Output on stdout

* Real baudrate equivalent to given number

### 1isip

Check if a string is an IP address

#### Arguments

* $i string Value to test if is an IP

#### Exit codes

* **0**: Confirm $1 is IP
* **1**: It's not an IP address

### 1host

Check files .hosts in lib/local and lib/remote, for a name, returning a valid IP

#### Arguments

* **$1** (string): Host name you need an IP

#### Exit codes

* **0**: 1host works fine
* **1**: Unknown or unaccessible host

#### Output on stdout

* IP address correspondent to given hostname

### 1iperf

Run iperf with a simple and functional configuration, connecting iperfd IP

#### Arguments

* **$1** (string): IP of a machine running 1iperfd

#### See also

* [1iperfd](#1iperfd)

### 1iperfd

Run iperf with a simple and functional configuration, as daemon, wainting connection

#### See also

* [1iperf](#1iperf)

### 1tcpdump

Run tcpdump with a simple and functional configuration

#### Arguments

* **$1** (string): Interface to listen

#### Exit codes

* **0**: tcpdump works
* **1**: tcpdump not found

### 1ison

Check using ping if machine is online

#### Arguments

* **$1** (string): Machine name (optional). -q if you need a quiet mode
* **$2** (string): URI or IP

#### Exit codes

* **0**: Machine is on
* **1**: Machine not accessible

### _1pressh

Internal function, pre-1ssh

#### Arguments

* **$1** (string): server or user@server, to use with ssh

#### Output on stdout

* user@machine, to use as argument for 1ssh

#### See also

* [1ssh](#1ssh)

### 1ssh

Access with SSH server (including extreme switchs)

#### Arguments

* **$1** (string): name or IP, or usr@IP
* **$2** (string): Additional options for ssh

### 1ports

Test open TCP ports

#### Arguments

* **$1** (string): IP
* **$2** (int): Port (or ports). Optional. Default: 1-1500

### 1allhosts

Return a possibly big string with all IP addresses in all interfaces

#### Arguments

* **$1** (int): (optional) Number of your interface. Default=all

#### Output on stdout

* All IP address in network inteface(s)

### 1mynet

Return network(s) for all your interfaces

#### Output on stdout

* Network addresses for all interfaces

### 1findport

Scan on network for an given port

#### Arguments

* **$1** (int): Port to scan

### 1areon

Check status for every host in given .hosts

#### Arguments

* **$1** (string): set of hosts

### 1xt-vlan

List VLANs in given switch

#### Arguments

* **$1** (string): IP or name (.hosts) for one or more switchs

### 1serial

Connect a serial port with appropriated program

#### Arguments

* **$1** (int): Bauds in 1bauds or traditional scale

### 1macvendor

Return MAC prefixes for a given vendor

#### Arguments

* **$1** (string): Vendor

#### Output on stdout

* MAC prefixes

### _nh1network.xt-backup

Do a single extreme switch backup

#### Arguments

* **$1** (string): Switch by extreme
* **$2** (string): Filename

### 1xt-backup

Backup from one or more switchs extreme

#### Arguments

* **$1** (string): host or group

