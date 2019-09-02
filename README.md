
NH1 is a toolkit with various commands:

In version 0.30, it offers:

___ Audio ___
1genbigmp3     Append various MP3 files in one single file
___ Miscelania ___
1du            to-do
1pdfopt        Compress a PDF file
1power         Print percentage for battery (notebook)
___ Network ___
1allhosts      Returns all hosts in all your networks
1findport      Search in all network every IP with given port open
1host          Return a valid ping-available IP for some host or domain name
1iperf         Run iperf connecting to a 1iperfd IP
1iperfd        Run iperfd, waiting for 1iperf connection
1isip          Return if a given string is an IP address
1ison          Return if server is on. Params: (-q for quiet or name), IP
1ports         Scan 1.500 ports for a given host
1ssh           Connect a SSH server (working with eXtreme)
1tcpdump       Run tcpdump in a given network interface

___ RPG ___
1dice          Roll a single dice from N faces (default: 6)
1roll          Roll dices with RPG formula: 2d10, 1d4+1...
1d4            Roll one d4 dice
1d6            Roll one d6 dice
1d8            Roll one d8 dice
1d10           Roll one d10 dice
1d12           Roll one d12 dice
1d20           Roll one d20 dice
1d100          Roll one d100 dice
1card          Sort a random playing card
___ Main ___
1install       to-do
1bashrc        Modify .bashrc to NH1 starts on bash start
1clean         Clean NH1 from memory (undo NH1 charge)
1tint          Write a string in another color
1update        Update your NH1, using git
1verbose       Enable/disable verbose mode
1version       List NH1 version and latest changes/updates
nh1localnet    to-do
nh1connect     to-do
nh1interactive to-do

To use it, clone repository and run "source nh1". Every functions will be available
in your bash for that section. To persist, run (after source nh1) "1bashrc".
