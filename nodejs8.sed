s/{{npm_version}}/6.13.4/g
s/{{node_version}}/8.17.0/g
s/{{node_version_major}}/8/g
s/{{arch_support}}/aarch64 ppc ppc64 ppc64le s390 s390x/g
s/{{exclusive_arch}}/%{ix86} x86_64 armv6hl armv7hl aarch64 ppc ppc64 ppc64le s390 s390x/g

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



s/{{bundled_cares_version}}/1.10.1-DEV/g
s/{{bundled_http_parser_version}}/2.9.3/g
s/{{bundled_icu-small_version}}/60.1/g
s/{{bundled_nghttp2_version}}/1.41.0/g
s/{{bundled_openssl_version}}/1.0.2s/g
s/{{bundled_uv_version}}/1.23.2/g
s/{{bundled_v8_version}}/6.2.414.78/g
