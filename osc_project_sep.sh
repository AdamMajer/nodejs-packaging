OSCRC=$HOME/.config/osc/oscrc
if [ ! -e $OSCRC ]; then
    OSCRC=$HOME/.oscrc
fi

PS=$((grep -s '^\s*project_separator\s*=' $OSCRC || echo "project_separator=:") | sed -e 's,^\s*project_separator\s*=\s*\(\S\+\)\s*$',\\1,)
