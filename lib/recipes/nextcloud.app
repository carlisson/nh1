# Description for install Nextcloud client via AppImage

APP_NAME="Nextcloud"
APP_DESCRIPTION="$(_1text "Client for Nextcloud desktop")"
APP_CATEGORIES="Utility;Internet"
APP_SITE="https://nextcloud.com/install/"

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
APP_PREFIX="Nextcloud-"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    curl -s https://nextcloud.com/install/ | tr '\n' ' ' | \
    sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/' | \
    sed 's/\(.*\)\///g'
}

# Code to effectly do the download
function APP_GET {
    if [ $# -eq 1 ]
    then
        _1sudo curl -O -L $(curl -s https://nextcloud.com/install/ | tr '\n' ' ' | \
        sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/')
    else
        curl -O -L $(curl -s https://nextcloud.com/install/ | tr '\n' ' ' | \
        sed 's/\(.*\)\(https\(.*\)\/Nextcloud-\(.*\)-x86_64\.AppImage\)\(.*\)/\2/')
    fi
}

