s/{{node_version}}/12.22.5/g
s/{{node_version_major}}/12/g

#
#
# openssl version
#
# Tumbleweed
# SLE12 SP5+
# SLE15 SP2+
s/{{intree_openssl}}/0%{?suse_version} >= 1550 || (0%{?sle_version} >= 120400 \&\& 0%{?sle_version} < 150000) || 0%{?sle_version} >= 150200/
#
#
# icu versions
s/{{intree_icu}}/0%{?suse_version} >= 1500/g
s/{{min_icu_version}}/64/g
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

# Git staging directory
s/{{git_branch}}/v12.x-staging/

# Extra Sources
s,{{SOURCES_EXTRA}},# Only required to run unit tests in NodeJS 10+ \
Source10:       update_npm_tarball.sh \
Source11:       node_modules.tar.xz,



s/{{bundled_brotli_version}}/1.0.9/g
s/{{bundled_cares_version}}/1.17.2/g
s/{{bundled_http_parser_version}}/2.9.4/g
s/{{bundled_icu-small_version}}/67.1/g
s/{{bundled_llhttp_version}}/2.1.3/g
s/{{bundled_nghttp2_version}}/1.41.0/g
s/{{bundled_openssl_version}}/1.1.1k/g
s/{{bundled_uv_version}}/1.40.0/g
s/{{bundled_uvwasi_version}}/0.0.11/g
s/{{bundled_v8_version}}/7.8.279.23/g
s/{{bundled_npm_version}}/6.14.14/g
