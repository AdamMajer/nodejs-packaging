s/{{npm_version}}/3.10.10/g
s/{{node_version}}/6.14.1/g
s/{{node_version_major}}/6/g
s/{{arch_support}}/aarch64 ppc ppc64 ppc64le s390 s390x/g
s/{{exclusive_arch}}/%{ix86} x86_64 armv7hl aarch64 ppc ppc64 ppc64le s390 s390x/g
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
