# Description for install via AppImage

APP_DESCRIPTION="Docker Kubernetes manager"

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
APP_PREFIX="rancher-desktop-"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    curl -s 'https://download.opensuse.org/repositories/isv:/Rancher:/stable/AppImage/?C=M;O=A' | \
        tr '\n' ' ' | \
        sed 's/\(.*\)\(rancher-desktop-[0-9]\(.*\)AppImage\)\(.*\)/\2/'
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

    $AGpre curl -O -L https://download.opensuse.org/repositories/isv:/Rancher:/stable/AppImage/"$( \
        curl -s 'https://download.opensuse.org/repositories/isv:/Rancher:/stable/AppImage/?C=M;O=A' | \
        tr '\n' ' ' | \
        sed 's/\(.*\)\(rancher-desktop-[0-9]\(.*\)AppImage\)\(.*\)/\2/'
    )"
}

