s/{{node_version}}/20.19.0/g
s/{{node_version_major}}/20/g

#
#
# openssl version - need OpenSSL 1.1.1+
s/{{intree_openssl}}/0%{?suse_version} >= 1500 || 0%{?sle_version} >= 120400 || 0%{?fedora_version} >= 35/g
#
#
# icu versions
s/{{intree_icu}}/0%{?suse_version} >= 1330 || 0%{?fedora_version} >= 35/g
s/{{min_icu_version}}/71/g
#
#
# libcares2 version
s/{{intree_libcares2}}/0%{?suse_version} >= 1330 || 0%{?fedora_version} >= 35/g
s/{{min_libcares2_version}}/1.17.0/g
#
#
# nghttp2 version
s/{{intree_nghttp2}}/0%{?suse_version} >= 1550/g
s/{{min_nghttp2_version}}/1.41.0/g

# brotli version
s/{{intree_brotli}}/0%{?suse_version} >= 1550/g
s/{{git_branch}}/master/

# Extra Sources
s,{{SOURCES_EXTRA}},\
# Python 3.4 compatible node-gyp \
### https://github.com/nodejs/node-gyp.git \
### git archive v7.1.2 | xz > node-gyp_7.1.2.tar.xz \
Source5:        node-gyp_7.1.2.tar.xz \
# Only required to run unit tests in NodeJS 10+ \
Source10:       update_npm_tarball.sh \
Source11:       node_modules.tar.xz,


s/{{bundled_brotli_version}}/1.1.0/g
s/{{bundled_cares_version}}/1.34.4/g
s/{{bundled_icu-small_version}}/76.1/g
s/{{bundled_llhttp_version}}/8.1.2/g
s/{{bundled_nghttp2_version}}/1.61.0/g
s/{{bundled_ngtcp2_version}}/1.1.0/g
s/{{bundled_openssl_version}}/3.0.15/g
s/{{bundled_uv_version}}/1.46.0/g
s/{{bundled_uvwasi_version}}/0.0.21/g
s/{{bundled_v8_version}}/11.3.244.8/g
s/{{bundled_npm_version}}/10.8.2/g
s/{{bundled_simdutf_version}}/6.0.3/g
s/{{bundled_ada_version}}/2.9.2/g

