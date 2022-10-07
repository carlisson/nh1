# Description for install Nextcloud client via AppImage

APP_DESCRIPTION="$(_1text "Code editor for KDE")"

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
APP_PREFIX="kate-"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    curl -s https://binary-factory.kde.org/job/Kate_Release_appimage-centos7/ |\
    tr '\n' ' ' | sed 's/\(.*\)\(kate-\(.*\)\.AppImage\)\(.*\)/\2/'
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

    $AGpre curl -O -L "https://binary-factory.kde.org/job/Kate_Release_appimage-centos7/lastSuccessfulBuild/artifact/$(APP_VERSION)"
}

