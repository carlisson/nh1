# Description for install Nextcloud client via AppImage

APP_DESCRIPTION="Web Browser"

# It can be:
#
# single: AppImage or simple binary file
# tarball: .tar.gz, with binaries (or sources)
# git: a git repository to clone
APP_TYPE="single"

# In case of tarball or git, BINARY is the executable file.
# For single, ignore it.
APP_BINARY=""

# Dependences. Specially useful to compilable apps
APP_DEPENDS=""

# Prefix for the filenames
APP_PREFIX="FreeTube_"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    # librewolf don't change the AppImage file name, but the download link references version.
    curl -s 'https://librewolf.net/installation/linux/' | tr '\n' ' ' | sed 's/\(.*\)\(LibreWolf-\(.*\)[0-9]\.x86_64\.AppImage\)\(.*\)/\2/'
}

# Code to effectly do the download
function APP_GET {
    local AGpre
    
    if [ $# -eq 1 ]
    then
        AGpre="_1sudo "
    else
        AGpre=""
    fi

    # Download the generic filename and rename it including version
    $AGpre curl -O -L $(curl -s 'https://librewolf.net/installation/linux/' | tr '\n' ' ' | sed 's/\(.*\)\(https\(.*\)\.x86_64\.AppImage\)\(.*\)/\2/')
    $AGpre mv LibreWolf.x86_64.AppImage $(curl -s 'https://librewolf.net/installation/linux/' | tr '\n' ' ' | sed 's/\(.*\)\(LibreWolf-\(.*\)[0-9]\.x86_64\.AppImage\)\(.*\)/\2/')
}

