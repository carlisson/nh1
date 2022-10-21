# Description for install an app via AppImage
# If there is a file <app>.png, a .desktop file will be created.

# Application Name
APP_NAME="Xonsh"

# Application Description _1text is used for translation
APP_DESCRIPTION="$(_1text "Powerfull shell with Python support")"

# Application Cattegories, to use in .desktop file.
APP_CATEGORIES="Utility;System"

# Mime tipes for application (it will be in .desktop file)
#APP_MIME=""

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

# Prefix for the filenames, to search installed old versions of app
APP_PREFIX="xonsh-"

# App suffix, file extension. Default for single is .AppImage
APP_SUFFIX=".AppImage"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    # <download-page>: put the download page url
    # tr: this command removes all break line characters, for better working of sed (next)
    # sed: replace REGEX with your regular expression. In this way, there ara 3 groups:
    #   1: anything before newest version filename
    #   2: the goal
    #   3: anything after this
    #      Examples of REGEX:
    #                        REGEX=CherryTree\(.*\).AppImage
    #                        ALL 2nd GROUP=\(href=\"\([0-9\.]*\)\/\"\)
    #      This formula is fine for a lot of apps, but you can need to create a more
    #      soffisticated strategy in some situations.
    echo -n "$(curl -s "https://github.com/xonsh/xonsh/releases" | grep -m1 "xonsh\/xonsh\/tree\/" | sed "s/\(.*\)\/tree\/\([0-9\.]*\)\"\ \(.*\)/xonsh-\2.AppImage/")"
}

# Code to effectly do the download
function APP_GET {
    local AGpre
    
    # This adjust allow 1app to install this app locally or globally.
    if [ $# -eq 1 ]
    then
        AGpre="_1sudo "
    else
        AGpre=""
    fi

    # curl -O -L <file-url>. File-url sometimes is similar to APP_VERSION output, bun not the same.
    # APP_VERSION will return just the filename. Now we need the full url.
    $AGpre curl -L "https://github.com/xonsh/xonsh/releases/download/$(
        curl -s "https://github.com/xonsh/xonsh/releases" | grep -m1 "xonsh\/xonsh\/tree\/" | sed "s/\(.*\)\/tree\/\([0-9\.]*\)\"\ \(.*\)/\2/"
    )/xonsh-x86_64.AppImage" --output "$(
        curl -s "https://github.com/xonsh/xonsh/releases" | grep -m1 "xonsh\/xonsh\/tree\/" | sed "s/\(.*\)\/tree\/\([0-9\.]*\)\"\ \(.*\)/xonsh-\2.AppImage/"
    )"
}

