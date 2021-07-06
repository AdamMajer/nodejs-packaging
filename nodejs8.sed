s/{{node_version}}/8.17.0/g
s/{{node_version_major}}/8/g

#
#
# openssl version
# Only Leap 42.2+, SLE 12 SP2+ and Tumbleweed have OpenSSL 1.0.2.
s/{{intree_openssl}}/0%{?suse_version} > 1320 || 0%{?sle_version} >= 120200/

#
#
# icu versions
s/{{intree_icu}}/0%{?suse_version} >= 1330/g
s/{{min_icu_version}}/57/g
#
#
# libcares2 version
s/{{intree_libcares2}}/0%{suse_version} >= 1330/g
s/{{min_libcares2_version}}/1.10.0/g

#
#
# nghttp2 version
s/{{intree_nghttp2}}/0%{suse_version} >= 1550/g
s/{{min_nghttp2_version}}/1.41.0/g

# Git staging directory
s/{{git_branch}}/v8.x-staging/

# Extra Sources
s,{{SOURCES_EXTRA}},\
# npm upgrade. manpages generated manually \
Source9:        https://github.com/npm/cli/archive/refs/tags/v6.14.13.tar.gz#/npm-v6.14.13.tar.gz \
Source90:       npm_man.tar.xz \
,


s/{{bundled_cares_version}}/1.10.1-DEV/g
s/{{bundled_http_parser_version}}/2.9.3/g
s/{{bundled_icu-small_version}}/60.1/g
s/{{bundled_nghttp2_version}}/1.41.0/g
s/{{bundled_openssl_version}}/1.0.2s/g
s/{{bundled_uv_version}}/1.23.2/g
s/{{bundled_v8_version}}/6.2.414.78/g
s/{{bundled_npm_version}}/6.13.4/g
