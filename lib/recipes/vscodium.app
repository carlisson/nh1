# Description for install Nextcloud client via AppImage

APP_DESCRIPTION="Editor for programmer"

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
APP_PREFIX="VSCodium-"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    curl -s 'https://github.com/VSCodium/vscodium/releases' | tr '\n' ' ' | sed 's/\(.*\)\(\/VSCodium\(.*\).deb\)"\(.*\)/\2/' | \
    sed 's/\(.*\)codium_\(.*\)_amd64\.deb/VSCodium-\2\.glibc2.17-x86_64.AppImage/'
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

    $AGpre curl -O -L "https://github.com"$(curl -s 'https://github.com/VSCodium/vscodium/releases' | tr '\n' ' ' | sed 's/\(.*\)\(\/VSCodium\(.*\).deb\)"\(.*\)/\2/' | \
    sed 's/\(.*\)codium_\(.*\)_amd64\.deb/\1VSCodium-\2\.glibc2.17-x86_64.AppImage/')

}

