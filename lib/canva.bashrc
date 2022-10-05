#!/bin/bash

# GLOBALS

_1CANVALOCAL="$_1UDATA/canvas"

# Generate partial menu
function _nh1canva.menu {
  echo "___ Canva Section ___"
  echo "--- Create images from SVG templates"
  _1menuitem X 1canva "List all templates or help for given template"
  _1menuitem X 1canvagen "Generate image from template" convert
  _1menuitem X 1canvaadd "Install or update a template"
  _1menuitem X 1canvadel "Remove installed template"
}

# Destroy all global variables created by this file
function _nh1canva.clean {
  unset _1CANVALOCAL _1CANVALIB
  unset -f 1canva 1canvagen 1canvaadd 1canvadel _nh1canva.complete
  unset -f _nh1canva.complete.canvaadd
}

# Auto-completion
function _nh1canva.complete {
    _1verb "Configuring auto-completion for 1canva"    
    complete -F _nh1canva.complete.canvaadd 1canvaadd
    complete -F _nh1canva.complete.list 1canvagen
}

# Alias-like
function _nh1canva.complete.canvaadd { _1compl 'svg' 0 0 0 0 ; }

function _nh1canva.complete.list {
  COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
        COMPREPLY=($(_1list $_1CANVALOCAL "svg"))
    fi
}

# Configure your template path
function _nh1canva.setup {
    if [ ! -d "$_1CANVALOCAL" ]
    then
        mkdir -p "$_1CANVALOCAL"
        cp "$_1LIB/templates/canva-template.svg" "$_1CANVALOCAL/hello.svg"
    fi
}

# List all installed templates
function 1canva {
    local _clist
    _nh1canva.setup
    
    #_clist=($(_nh1canva.list))
    _clist=($(_1list $_1CANVALOCAL "svg"))
    
    echo "Templates: ${_clist[@]}"
    
    if [ ${#_clist[@]} -eq 0 ]
    then
        echo "No template found."
    fi
}

# List help for template or apply it
# @param template name
# @param output file (.jpg, .png or other)
# @param substitutions in key=value syntax
function 1canvagen {
    local iter tempf tempi tempib
    subst=""
    case $# in
        0)
            echo "Usages:"
            echo "  1canvagen <template>"
            echo "  1canvagen <template> <outputfile> [key=value]*"
            ;;
        1|2)        
            cat "$_1CANVALOCAL/$1.svg" | tr '\n' ' ' | sed 's/\(.*\)1canva-en-ini\(.*\)1canva-en-end\(.*\)/\2/'
            ;;
        *)
            template="$1"
            fileout="$2"
            shift 2
            tempf=$(mktemp -u)
            
            tempi=$(mktemp -u).svg
            
            cp "$_1CANVALOCAL/$template.svg" $tempi
            echo "#!/bin/bash" > $tempf
            echo "pushd" $(dirname $tempi) "> /dev/null" >> $tempf
            
            tempib=$(basename $tempi)
            for iter in "$@"
            do
                echo $iter | sed "s/\(.*\)=\(.*\)/sed -i 's\/-=\\\[\1\\\]=-\/\2\/g' $tempib/" >> $tempf
                # $(echo $(echo $iter | sed 's/\(.*\)=\(.*\)/sed -i "s\/-=[\1]=-\/\2\/g"/') $tempf)
            done

            echo "popd > /dev/null" >> $tempf

            bash $tempf
            rm $tempf
            
            convert $tempi $fileout
            rm $tempi
            ;;
    esac
}

# Add a svg template
# @param SVG to add
function 1canvaadd {
    local ni no
    case $# in
        1)
            ni="$1"
            no="$(basename $1)"
            ;;
        2)
            ni="$1"
            no="$2"
            if [ "${no: -4}" != ".svg" ]
            then
                no="$no.svg"
            fi
            ;;
        *)
            echo "Usage: 1canvaadd <svg-initial> (<name-of-template>)"
            return
            ;;
    esac
    cp "$ni" "$_1CANVALOCAL/$no"
}

# Remove a svg template
# @param Name of template to remove
function 1canvadel {
    if [ -f "$_1CANVALOCAL/$1.svg" ]
    then
        rm "$_1CANVALOCAL/$1.svg"
    else
        print "Template $1 not found."
    fi
}