#!/usr/bin/perl

use strict;
use warnings;

# Reads spec file from STDIN
# Removes references to patches that are not for current version
# of nodejs.
#     Patch10: foo.patch    # PATCH_FOR: 4, 6
#     Patch11: goo.patch
# will have Patch10 removed in all versions not 4 and 6
#
# version prefix of + means staging only
#                   = means release only

my @removed_patches;
my $cur_version=$ARGV[0];
my $staging_matching;

$staging_matching = ($cur_version =~ /staging-/) ? '\+' : '=';
$cur_version =~ s/nodejs|staging-//;

NEXT_LINE:
while (<STDIN>) {
    my @a;
    if (@a = m/Patch([\d]+):.*PATCH_FOR:(.*)$/) {
        if (!($a[1] =~ /[\s,:]${staging_matching}?${cur_version}([,\s\n]|$)/)) {
            push @removed_patches, $a[0];
            next;
        }

        # rpmbuild file explodes on this, so remove this comment/markup
        s/\s+#\s*PATCH_FOR:.*$//;
    }

    if (@a = m/%patch -P ([\d]+)\b/) {
        foreach my $p (@removed_patches) {
            if ($a[0] == $p) {
                next NEXT_LINE;
            }
        }
    }

    print;
}

