#!/bin/bash

MODE="default"
STAGING=

while getopts "NMg" OPTION; do
    if   [ "$OPTION" = "N" ]; then MODE="node"
    elif [ "$OPTION" = "M" ]; then MODE="npm"
    elif [ "$OPTION" = "g" ]; then STAGING="y"
    else MODE="default"
    fi
done

shift $(( $OPTIND - 1 ))

if [ ${#@} -ne 1 ] || ! [[ "$1" =~ ^[0-9]+$ ]] || [ $1 -lt 6 ] || [ $1 -gt 42 ]; then
    echo " syntax:  bundling.sh [-M | -N] node_major_version"
    echo "    -M - sed substitutions for main node"
    echo "    -N - sed substitutions for npm"
    echo "    -d - non-npm package bundled versions"
    echo "    -g - operate on staging diretories"
    echo "  eg. bundling.sh 10"
    exit -1
fi

NODE_VERSION=$1
PROCESSED_NPM_DEPS=

## KNOWN_BUNDLED="acorn acorn-plugins brotli cares histogram icu-small llhttp nghttp2"

# arg $1 - bundle
# returns:   $CURRENT_VERSION = version of currently saved bundle or "" if nothing
function load_current_version
{
    CURRENT_VERSION=$(grep "{{bundled_$1_version}}" nodejs$NODE_VERSION.sed | awk -F '/' '{print $3}')
    if [ -z "$CURRENT_VERSION" ]; then
        CURRENT_VERSION="not bundled"
    fi
}


function save_current_version
{
    if [ "$CURRENT_VERSION" = "not bundled" ]; then
        # append version to file
        echo "s/{{bundled_$1_version}}/$BUNDLED_VERSION/g" >> nodejs$NODE_VERSION.sed
    else
        sed -i.bak -e "s,\\({{bundled_$1_version}}/\\).*$,\\1$BUNDLED_VERSION/g," nodejs$NODE_VERSION.sed
    fi
}


# extracts version from a define as,
#   #define SOME_VERSION "1.2.3"
#   where 
#     $1 - filename to check
#     $2 - define to grep for
function extract_version_from_string_define
{
    if [ -f $1 ]; then
        BUNDLED_VERSION=$(grep "$2" $1 | awk '{print $3}' | sed -e 's,",,g')
    fi
}

function load_brotli_version
{
    if [ -f c/common/version.h ]; then
        local VER=$(grep BROTLI_VERSION c/common/version.h | awk '{print $3}')
        BUNDLED_VERSION=$(node -e "a=$VER; console.log((a >> 24) + '.' + ((a >> 16)&0xFF) + '.' + (a & 0xFF))")
    fi
}

function load_cares_version
{
    extract_version_from_string_define include/ares_version.h "ARES_VERSION_STR"
}

function load_http_parser_version
{
    if [ -f http_parser.h ]; then
        local MAJOR=$(grep HTTP_PARSER_VERSION_MAJOR http_parser.h | awk '{print $3}')
        local MINOR=$(grep HTTP_PARSER_VERSION_MINOR http_parser.h | awk '{print $3}')
        local PATCH=$(grep HTTP_PARSER_VERSION_PATCH http_parser.h | awk '{print $3}')

        BUNDLED_VERSION="$MAJOR.$MINOR.$PATCH"
    fi
}

function load_icu-small_version
{
    extract_version_from_string_define source/common/unicode/uvernum.h '#define U_ICU_VERSION '
}

function load_nghttp2_version
{
    extract_version_from_string_define lib/includes/nghttp2/nghttp2ver.h 'NGHTTP2_VERSION '
}

function load_nghttp3_version
{
    extract_version_from_string_define lib/includes/nghttp3/version.h 'NGHTTP3_VERSION '
}

function load_ngtcp2_version
{
    extract_version_from_string_define lib/includes/ngtcp2/version.h 'NGTCP2_VERSION '
}

function load_openssl_version
{
    if [ -f openssl/include/openssl/opensslv.h ]; then
        local VER=$(grep OPENSSL_VERSION_NUMBER openssl/include/openssl/opensslv.h | awk '{print $4}' | sed 's,L,,')
        BUNDLED_VERSION=$(node -e "a=$VER; l=a>>4&0xFF; l=(l>0) ? String.fromCodePoint(96+l):''; console.log((a>>4+8+8+8 & 0xFF) + '.' + (a>>4+8+8&0xFF) + '.' + (a>>4+8&0xFF) + l)")
    fi
}

function load_uv_version
{
    F=include/uv/version.h
    if [ ! -f $F ]; then
        F=include/uv-version.h
    fi

    if [ -f $F ]; then
        local MAJOR=$(grep 'define UV_VERSION_MAJOR' $F | awk '{print $3}')
        local MINOR=$(grep 'define UV_VERSION_MINOR' $F | awk '{print $3}')
        local PATCH=$(grep 'define UV_VERSION_PATCH' $F | awk '{print $3}')

        BUNDLED_VERSION="$MAJOR.$MINOR.$PATCH"
    fi
}

function load_v8_version
{
    local F=include/v8-version.h
    if [ -f $F ]; then
        local MAJOR=$(grep 'V8_MAJOR_VERSION' $F | awk '{print $3}')
        local MINOR=$(grep 'V8_MINOR_VERSION' $F | awk '{print $3}')
        local BUILD=$(grep 'V8_BUILD_NUMBER' $F | awk '{print $3}')
        local PATCH=$(grep 'V8_PATCH_LEVEL' $F | awk '{print $3}')

        BUNDLED_VERSION="$MAJOR.$MINOR.$BUILD.$PATCH"
    fi
}

function load_llhttp_version
{
    if [ -f include/llhttp.h ]; then
        local MAJOR=$(grep 'define LLHTTP_VERSION_MAJOR' include/llhttp.h | awk '{print $3}')
        local MINOR=$(grep 'define LLHTTP_VERSION_MINOR' include/llhttp.h | awk '{print $3}')
        local PATCH=$(grep 'define LLHTTP_VERSION_PATCH' include/llhttp.h | awk '{print $3}')

        BUNDLED_VERSION="$MAJOR.$MINOR.$PATCH"
    fi
}

function load_uvwasi_version
{
    if [ -f include/uvwasi.h ]; then
        local MAJOR=$(grep 'define UVWASI_VERSION_MAJOR' include/uvwasi.h | awk '{print $3}')
        local MINOR=$(grep 'define UVWASI_VERSION_MINOR' include/uvwasi.h | awk '{print $3}')
        local PATCH=$(grep 'define UVWASI_VERSION_PATCH' include/uvwasi.h | awk '{print $3}')

        BUNDLED_VERSION="$MAJOR.$MINOR.$PATCH"
    fi
}

function load_npm_version
{
    if [ -f package.json ]; then
        BUNDLED_VERSION=$(node -e "console.log(JSON.parse(fs.readFileSync('package.json')).version)")
    fi
}


# arg $1 - bundle
# returns:   $BUNDLED_VERSION = version detected upstream
#   exits with status code 20 if cannot determine version of known bundle
#   exits with status code 21 if unknown bundle
function load_bundled_version
{
    local PKG=$1
    push_node_dir
    cd deps/$PKG

    BUNDLED_VERSION=""

    case $PKG in
        (acorn|acorn-plugins|node-inspect|gtest|zlib|histogram):
        # These are npm packages so handled elsewhere
        # or excluded, like gtest
        popd > /dev/null
        return
        ;;
        (brotli|cares|http_parser|icu-small|nghttp2|nghttp3|openssl|uv|v8|llhttp|uvwasi|ngtcp2|npm):
        load_${PKG}_version
        ;;
        (*):
        echo " !!! unknown bundle $PKG !!!"
        exit 21
        ;;
    esac

    popd > /dev/null

    if [ -z "$BUNDLED_VERSION" ]; then
        echo "!!! cannot get bundled version for $PKG! FIX!"
        exit 20
    fi
}

function expand_tarball
{
    if [ -z "$STAGING" ]; then
        pushd devel:languages:nodejs/nodejs$NODE_VERSION > /dev/null
        tar Jxf node-v$NODE_FULL_VERSION.tar.xz
        popd > /dev/null
    else
        pushd devel:languages:nodejs:staging/nodejs$NDOE_VERSION > /dev/null
        for i in `ls -t node-git.*.tar`; do
            tar Jxf $i
            break
        done
        popd > /dev/null
    fi
    
}

function push_node_dir
{
    local dir;
    if [ -z "$STAGING" ]; then
        dir=devel:languages:nodejs/nodejs$NODE_VERSION/node-v$NODE_FULL_VERSION
    else
        dir=devel:languages:nodejs:staging/nodejs$NODE_VERSION/node-git.*/
    fi

    if [ ! -d $dir ]; then
        expand_tarball
        if [ ! -d $dir ]; then
            echo "Cannot untar the tarball" > /dev/stderr
            exit 15
        fi
    fi

    pushd $dir > /dev/null
}

function find_npm_packages
{
    local PKGS

    push_node_dir
    cd deps
    if [ "$MODE" = "npm" ]; then
        PKGS=$(find -name package.json -path './npm/node_modules/*' -not -path '*/test/*' | sort)
    else
        PKGS=$(find -name package.json -not -path './npm/*' -not -path './v8/*' -not -path '*/test/*' | sort)
    fi

    for PKG in $PKGS; do
        node -e "v=JSON.parse(fs.readFileSync('$PKG').toString()); \
            if (v.name.length > 0) { \
                let d=['Provides:       bundled(node-', v.name, ') = ', v.version, '\\\\n']; \
                process.stdout.write(d.join('')); \
            } else { console.error('Error processing %s', '$PKG'); }"
    done

    popd > /dev/null
}




# make nodejs$NODE_VERSION || exit 10
NODE_FULL_VERSION=$(grep {{node_version}} nodejs$NODE_VERSION.sed | awk -F '/' '{print $3}')

push_node_dir
DEPS=$(ls deps)
popd > /dev/null

if [ "$MODE" = "npm" ] || [ "$MODE" = "node" ]; then
    echo -n "s,{{${MODE}_npm_bundles}},"
    find_npm_packages
    echo ','
    exit 0;
fi

for bundle in $DEPS
do
        load_current_version $bundle
        load_bundled_version $bundle

        if [ "$CURRENT_VERSION" = "$BUNDLED_VERSION" ]; then
            echo " --> $bundle unchanged -- $CURRENT_VERSION"
        elif [ "$CURRENT_VERSION" = "not bundled" ] && [ "x$BUNDLED_VERSION" = "x" ]; then
            true
        else
            echo " **> $bundle UPDATED   -- '$CURRENT_VERSION' -> '$BUNDLED_VERSION'"
            save_current_version $bundle
        fi
done

