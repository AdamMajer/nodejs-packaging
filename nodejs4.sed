s/{{npm_version}}/2.15.11/g
s/{{node_version}}/4.9.1/g
s/{{node_version_major}}/4/g
s/{{arch_support}}/aarch64 ppc ppc64 ppc64le s390 s390x/g
s/{{exclusive_arch}}/%{ix86} x86_64 armv7hl aarch64 ppc ppc64 ppc64le/g

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
# libcares2 version - option unavailable in Nodejs4
s/{{intree_libcares2}}/0/g
s/{{min_libcares2_version}}/1.10.0/g
#
#
# nghttp2 version - unavailable in Node 6.x
s/{{intree_nghttp2}}/0/g
s/{{min_nghttp2_version}}/1.31.0/g

# Git staging directory
s/{{git_branch}}/v4.x-staging/

