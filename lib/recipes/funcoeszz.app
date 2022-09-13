# Description for install Nextcloud client via AppImage

APP_DESCRIPTION="A set of utilities for shell"

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

# Prefix for filenames
APP_PREFIX="funcoeszz-"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    curl -s http://funcoeszz.net/download/ | tr '\n' ' ' | \
    sed 's/\(.*\)\/download\/\(funcoeszz-\(.*\).sh\)\(.*\)/\2/' | \
    sed 's/"\(.*\)//g'
}

# Code to effectly do the download
#alias APP_GET="curl -O -L "http://funcoeszz.net/download/$_NANEW"

function APP_GET {
    if [ $# -eq 1 ]
    then
        _1sudo curl -O -L http://funcoeszz.net/download/$(curl -s http://funcoeszz.net/download/ | tr '\n' ' ' | \
        sed 's/\(.*\)\/download\/\(funcoeszz-\(.*\).sh\)\(.*\)/\2/' | \
        sed 's/"\(.*\)//g')
    else
        curl -O -L http://funcoeszz.net/download/$(curl -s http://funcoeszz.net/download/ | tr '\n' ' ' | \
        sed 's/\(.*\)\/download\/\(funcoeszz-\(.*\).sh\)\(.*\)/\2/' | \
        sed 's/"\(.*\)//g')
    fi
}

