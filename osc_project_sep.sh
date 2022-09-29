PS=$((grep '^\s*project_separator\s*=' ~/.oscrc || echo "project_separator=:") | sed -e 's,^\s*project_separator\s*=\s*\(\S\+\)\s*$',\\1,)

