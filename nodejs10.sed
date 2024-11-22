s/{{node_version}}/10.24.1/g
s/{{node_version_major}}/10/g

#
#
# openssl version - need version 1.1+
s/{{intree_openssl}}/0%{?suse_version} >= 1500 || 0%{?sle_version} >= 120400/

#
#
# icu versions
s/{{intree_icu}}/0%{?suse_version} >= 1330/g
s/{{min_icu_version}}/57/g
#
#
# libcares2 version
s/{{intree_libcares2}}/0%{suse_version} >= 1330/g
s/{{min_libcares2_version}}/1.17.0/g
#
#
# nghttp2 version
s/{{intree_nghttp2}}/0%{suse_version} >= 1550/g
s/{{min_nghttp2_version}}/1.41.0/g

# brotli version
s/{{intree_brotli}}/0%{suse_version} >= 1550/g


# Git staging directory
s/{{git_branch}}/v10.x-staging/

# Extra Sources
s,{{SOURCES_EXTRA}},\
# npm upgrade. manpage generated manually \
Source9:        https://github.com/npm/cli/archive/refs/tags/v6.14.16.tar.gz#/npm-v6.14.16.tar.gz \
Source90:       npm_man.tar.xz \
# Only required to run unit tests in NodeJS 10+ \
Source10:       update_npm_tarball.sh \
Source11:       node_modules.tar.xz \
,



s/{{bundled_brotli_version}}/1.0.7/g
s/{{bundled_cares_version}}/1.15.0/g
s/{{bundled_icu-small_version}}/64.2/g
s/{{bundled_nghttp2_version}}/1.41.0/g
s/{{bundled_openssl_version}}/1.1.1k/g
s/{{bundled_uv_version}}/1.34.2/g
s/{{bundled_v8_version}}/6.8.275.32/g
s/{{bundled_npm_version}}/6.14.16/g
s/{{bundled_llhttp_version}}/2.1.6/g
