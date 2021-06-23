s/{{node_version}}/16.4.0/g
s/{{node_version_major}}/16/g
s/{{exclusive_arch}}/%{arm} %{ix86} x86_64 aarch64 ppc64 ppc64le s390x/g

#
#
# openssl version - need OpenSSL 1.1.1+
s/{{intree_openssl}}/0%{?suse_version} >= 1550 || 0%{?sle_version} >= 120500/
#
#
# icu versions
s/{{intree_icu}}/0%{?suse_version} >= 1550 /g
s/{{min_icu_version}}/68/g
#
#
# libcares2 version
s/{{intree_libcares2}}/0%{?suse_version} >= 1330/g
s/{{min_libcares2_version}}/1.17.0/g
#
#
# nghttp2 version
s/{{intree_nghttp2}}/0%{?suse_version} >= 1550/g
s/{{min_nghttp2_version}}/1.41.0/g

s/{{git_branch}}/v16.x-staging/

# Extra Sources
s,{{SOURCES_EXTRA}},# Only required to run unit tests in NodeJS 10+ \
Source10:       update_npm_tarball.sh \
Source11:       node_modules.tar.xz,



s/{{bundled_brotli_version}}/1.0.9/g
s/{{bundled_cares_version}}/1.17.1/g
s/{{bundled_icu-small_version}}/69.1/g
s/{{bundled_llhttp_version}}/6.0.2/g
s/{{bundled_nghttp2_version}}/1.42.0/g
s/{{bundled_ngtcp2_version}}/0.1.0-DEV/g
s/{{bundled_openssl_version}}/1.1.1k/g
s/{{bundled_uv_version}}/1.41.0/g
s/{{bundled_uvwasi_version}}/0.0.11/g
s/{{bundled_v8_version}}/9.1.269.36/g
s/{{bundled_npm_version}}/7.18.1/g
