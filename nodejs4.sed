s/{{npm_version}}/2.15.11/
s/{{node_version}}/4.7.1/
s/{{node_version_major}}/4/
s/{{arch_support}}/aarch64 ppc ppc64 ppc64le s390 s390x/
s/{{exclusive_arch}}/%{ix86} x86_64 armv7hl aarch64 ppc ppc64 ppc64le/
#
#
# icu versions
s/{{intree_icu}}/0%{?suse_version} >= 1200/
s/{{min_icu_version}}/52/
#
#
# libcares2 version - option unavailable in Nodejs4
s/{{intree_libcares2}}/0/
s/{{min_libcares2_version}}/1.10.0/
