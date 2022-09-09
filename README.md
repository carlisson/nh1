
NH1 is a toolkit with various commands:

In version 0.48, it offers:

## App Installer
* 1app           List all available apps
* 1appl          List all local apps
* 1appg          List all global apps
* 1applsetup     Configure your local path/dir
* 1appgsetup     Configure global path/dir
* 1appladd       Install or update an app locally
* 1appgadd       Install or update an app globaly
* 1applupd       Update all local apps
* 1appgupd       Update all global apps
* 1appldel       Remove a local app
* 1appgdel       Remove a global app
* 1applclear     Remove old versions for a local app (or all)
* 1appgclear     Remove old versions for a global app (or all)


## Audio
* 1alarm         Play an audio alarm
* 1beat          Play a simple beat in given frequency
* 1genbigmp3     Append various MP3 files in one single file
* 1id3get        Extract metadata from an MP3 to a TXT
* 1id3set        Create a new MP3 file applying metadata from a TXT
* 1ogg2mp3       Convert a ogg file to mp3
* 1svideo        Create static video from MP3 and PNG
* 1yt3           Extract Youtube video to MP3

## Miscelania
* 1ajoin         Join an array, using first param as delimiter
* 1du            Disk usage
* 1escape        Rename a file or dir, excluding special chars
* 1pdfopt        Compress a PDF file
* 1pomo          Run one pomodoro (default is 25min)
* 1power         Print percentage for battery (notebook)


## Network
* 1allhosts      Returns all hosts in all your networks
* 1findport      Search in all network every IP with given port open
* 1host          Return a valid ping-available IP for some host or domain name
* 1iperf         Run iperf connecting to a 1iperfd IP
* 1iperfd        Run iperfd, waiting for 1iperf connection
* 1isip          Return if a given string is an IP address
* 1ison          Return if server is on. Params: (-q for quiet or name), IP
* 1mynet         Return all networks running on network interfaces
* 1ports         Scan 1.500 ports for a given host
* 1ssh           Connect a SSH server (working with eXtreme)
* 1tcpdump       Run tcpdump in a given network interface

## RPG
* 1dice          Roll a single dice from N faces (default: 6)
* 1roll          Roll dices with RPG formula: 2d10, 1d4+1...
* 1d4            Roll one d4 dice
* 1d6            Roll one d6 dice
* 1d8            Roll one d8 dice
* 1d10           Roll one d10 dice
* 1d12           Roll one d12 dice
* 1d20           Roll one d20 dice
* 1d100          Roll one d100 dice
* 1card          Sort a random playing card

## Main
* 1bashrc        Modify .bashrc to NH1 starts on bash start
* 1clean         Clean NH1 from memory (undo NH1 charge)
* 1tint          Write a string in another color
* 1update        Update your NH1, using git
* 1verbose       Enable/disable verbose mode
* 1version       List NH1 version and latest changes/updates

To use it, download the latest release or clone repository and run "source nh1". Every functions will be available
in your bash for that section. To persist, run (after source nh1) "1bashrc".

If you have used git, you can update NH1 with 1update.
