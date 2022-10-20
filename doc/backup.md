# backup.bashrc

Tools for backup

## Overview

Generate partial menu

## Index

* [_nh1backup.menu](#_nh1backupmenu)
* [_nh1backup.clean](#_nh1backupclean)
* [_nh1backup.names](#_nh1backupnames)
* [_nh1backup.complete](#_nh1backupcomplete)
* [_nh1backup.customvars](#_nh1backupcustomvars)
* [_nh1backup.init](#_nh1backupinit)
* [_nh1backup.bdir](#_nh1backupbdir)
* [_nh1backup.info](#_nh1backupinfo)
* [_nh1backup.log](#_nh1backuplog)
* [_nh1backup.maxcontrol](#_nh1backupmaxcontrol)
* [_nh1backup.nextfile](#_nh1backupnextfile)
* [1backup](#1backup)
* [1backlist](#1backlist)

### _nh1backup.menu

Generate partial menu

### _nh1backup.clean

Destroy all global variables created by this file

### _nh1backup.names

List backup names from saved backups

#### Output on stdout

* List of backup names

### _nh1backup.complete

Autocomplete

### _nh1backup.customvars

Load variables defined by user

### _nh1backup.init

Initializing NH1 Backup

### _nh1backup.bdir

Returns right backup dir

#### Output on stdout

* Path where to save backups now

### _nh1backup.info

Information about possible custom vars

### _nh1backup.log

Registry log message in 3 locals.

### _nh1backup.maxcontrol

Controls max number of files

#### Arguments

* **$1** (string): Name (id)
* **$2** (string): Directory for saved backups

### _nh1backup.nextfile

Returns next filename for base and extension

#### Arguments

* **$1** (string): Name (id)
* **$2** (string): Extension

#### Output on stdout

* File name for use in next backup operation

### 1backup

Make backup of a directory

#### Arguments

* **$1** (string): Name (id) for backup
* **$2** (string): Directory to backup

### 1backlist

List all backups for one name (id)

#### Arguments

* **$1** (string): Name (id)

