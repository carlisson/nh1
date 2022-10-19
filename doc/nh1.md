# nh1

Simple shell end user swiss army knife (toolkit) 

## Overview

A set of tools for shell.
* 1app - AppImage package manager
* audio, backup, network and rpg tools
* 1canva - create images from SVG templates
* other things
Documentation for shdoc - https://github.com/reconquest/shdoc

## Index

* [1tint](#1tint)
* [_1verb](#_1verb)

### 1tint

Set text color in shell

#### Example

```bash
echo "test: $(1tint 6 "Hello World")"
```

#### Arguments

* **$1** (int): The color number (optional)
* **$2** (string): Text to color

#### Exit codes

* **0**: If successful.
* **1**: If an empty string passed.

## Internal functions

Print only if NH1 is in verbose mode

### _1verb

Print only if NH1 is in verbose mode

#### Arguments

* **$1** (string): Message to print

