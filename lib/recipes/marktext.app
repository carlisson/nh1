# Description for install an app via AppImage
# If there is a file <app>.png, a .desktop file will be created.

# Application Name
APP_NAME="Marktext"

# Application Description _1text is used for translation
APP_DESCRIPTION="$(_1text "Markdown editor")"

# Application Cattegories, to use in .desktop file.
APP_CATEGORIES="Office"

# Mime tipes for application (it will be in .desktop file)
APP_MIME="text/x-markdown"

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
APP_PREFIX="marktext-"

# App suffix, file extension. Default for single is .AppImage
#APP_SUFFIX=".AppImage"

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
    curl -s '<download-page>' | tr '\n' ' ' | sed 's/\(.*\)\(REGEX\)\(.*\)/\2/'
    echo "marktext-$(_nh1app.ghversion marktext marktext).AppImage"
}

# Code to effectly do the download
function APP_GET {
    local AGpre AGver
    
    # This adjust allow 1app to install this app locally or globally.
    if [ $# -eq 1 ]
    then
        AGpre="_1sudo "
    else
        AGpre=""
    fi

    AGver="$(_nh1app.ghversion marktext marktext)"

    # curl -O -L <file-url>. File-url sometimes is similar to APP_VERSION output, bun not the same.
    # APP_VERSION will return just the filename. Now we need the full url.
    $AGpre curl -o "marktext-$AGver.AppImage" -L "https://github.com/marktext/marktext/releases/download/v$AGver/marktext-x86_64.AppImage"
}

