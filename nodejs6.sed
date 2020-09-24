s/{{node_version}}/6.17.1/g
s/{{node_version_major}}/6/g
s/{{arch_support}}/aarch64 ppc ppc64 ppc64le s390 s390x/g
s/{{exclusive_arch}}/%{ix86} x86_64 armv7hl aarch64 ppc ppc64 ppc64le s390 s390x/g

#
#
# openssl version
# Only Leap 42.2+, SLE 12 SP2+ and Tumbleweed have OpenSSL 1.0.2.
s/{{intree_openssl}}/0%{?suse_version} > 1320 || 0%{?sle_version} >= 120200/

#
#
# icu versions
s/{{intree_icu}}/0%{?suse_version} >= 1200/g
s/{{min_icu_version}}/52/g
#
#
# libcares2 version
s/{{intree_libcares2}}/0%{suse_version} >= 1330/g
s/{{min_libcares2_version}}/1.10.0/g
#
#
# nghttp2 version - unavailable in Node 4.x
s/{{intree_nghttp2}}/0/g
s/{{min_nghttp2_version}}/1.31.0/g

# Git staging directory
s/{{git_branch}}/v6.x-staging/

# New npm
s,{{SOURCES_EXTRA}},# Update npm version \
Source10:       npm.tar.xz,



s/{{bundled_cares_version}}/1.10.1-DEV/g
s/{{bundled_http_parser_version}}/2.9.3/g
s/{{bundled_icu-small_version}}/58.2/g
s/{{bundled_openssl_version}}/1.0.2r/g
s/{{bundled_uv_version}}/1.16.1/g
s/{{bundled_v8_version}}/5.1.281.111/g
s/{{bundled_npm_version}}/6.13.4/g
