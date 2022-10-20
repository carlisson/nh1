# rpg.bashrc

RPG tools

## Overview

Generate partial menu (for RPG functions)

## Index

* [_nh1rpg.menu](#_nh1rpgmenu)
* [_nh1rpg.clean](#_nh1rpgclean)
* [_nh1rpg.complete](#_nh1rpgcomplete)
* [_nh1rpg.complete.draw](#_nh1rpgcompletedraw)
* [_nh1rpg.init](#_nh1rpginit)
* [_nh1rpg.customvars](#_nh1rpgcustomvars)
* [_nh1rpg.info](#_nh1rpginfo)
* [1d4](#1d4)
* [1d6](#1d6)
* [1d8](#1d8)
* [1d10](#1d10)
* [1d12](#1d12)
* [1d20](#1d20)
* [1d100](#1d100)
* [1dice](#1dice)
* [1roll](#1roll)
* [1card](#1card)
* [1drawlist](#1drawlist)
* [1drawadd](#1drawadd)
* [1draw](#1draw)
* [1drawdel](#1drawdel)

### _nh1rpg.menu

Generate partial menu (for RPG functions)

### _nh1rpg.clean

Destroy all global variables created by this file

### _nh1rpg.complete

Auto-completion

### _nh1rpg.complete.draw

Auto-completion for 1draw

### _nh1rpg.init

Initial commands

### _nh1rpg.customvars

Apply custom vars from config file

### _nh1rpg.info

General information about variables and customizing

### 1d4

Rolls a 4-sided dice

#### Output on stdout

* Result for rolling

#### See also

* [1dice](#1dice)

### 1d6

Rolls a 6-sided dice

#### Output on stdout

* Result for rolling

#### See also

* [1dice](#1dice)

### 1d8

Rolls an 8-sided dice

#### Output on stdout

* Result for rolling

#### See also

* [1dice](#1dice)

### 1d10

Rolls a 10-sided dice

#### Output on stdout

* Result for rolling

#### See also

* [1dice](#1dice)

### 1d12

Rolls a 12-sided dice

#### Output on stdout

* Result for rolling

#### See also

* [1dice](#1dice)

### 1d20

Rolls a 20-sided dice

#### Output on stdout

* Result for rolling

#### See also

* [1dice](#1dice)

### 1d100

Rolls a 100-sided dice

#### Output on stdout

* Result for rolling

#### See also

* [1dice](#1dice)

### 1dice

Generate a random number, like from a dice from N sides

#### Arguments

* **$1** (int): number of sides of the dice (default 6)

#### Output on stdout

* Result for rolling

#### See also

* [1roll](#1roll)

### 1roll

Roll dices from a RPG formula

#### Arguments

* **$1** (string): Formula like XdY+Z or XdY-Z

#### See also

* [1dice](#1dice)

### 1card

Random playing card

### 1drawlist

List all groups/lists from where to draw elements

#### Arguments

* **$1** (string): group name (optional)

### 1drawadd

Add a group list from a text file, with one option per line

#### Arguments

* **$1** (string): Input text file

### 1draw

Withdraw one item from a given group

#### Arguments

* **$1** (string): Group name

### 1drawdel

Delete a group list

#### Arguments

* **$1** (string): Group name

