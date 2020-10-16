Overview
--------

Templates for NodeJS packages in OpenSUSE.

For any particular version of NodeJS, like 12 or 6 (henceforth
referred to as X), the following work flow that occurs in the Makefile,
run `make nodeX`

1. NodeJS package nodeX is checkout from the main project
2. Files in the common/ directory are copied directly to the package
3. Files in the nodeX/ directory are copied to the package
4. `nodejsN.spec` file is generated using `sed` with help of
   `nodejs.spec.in` and `nodejsX.sed` script and bundling.js
    and is copied to the package file.

Branch specific patches can be annotated with PATCH_FOR line-end
comment after PatchX: header. The `patch.pl` script will parse
and remove these comments along with the patches and relevant %patchX
statements. For example

      Patch10: foo.patch    # PATCH_FOR: 4, 6
      Patch11: goo.patch

will have Patch10 removed in all versions except 4 and 6, this includes the
`%patch10` line in the `%setup` section of the spec file.

Please send pull requests when doing version updates via GitHub
instead of OBS submit requests, since changelogs are tracked in
GitHub (at least for now).

To update individual changelogs, use `osc vc` in specific version's
subdirectory. To prepend all changelogs, use `osc vc` in the main
directory and run `make` to prepend all changelogs.

`common/` subdirectory is only for patches that apply to all NodeJS
versions. It's rather rare to use this now and mainly used only for
the keyring.

To reduce clutter, patch comments should be found in headers of patches,
not in the .spec files.

NOTE: Upstream tarballs are not kept in Git repository.


Git stagings
------------

__Hint__: If you run `make all` (or just `make`), you will need to fetch
node's git repo beforehand. If you only wish to test with released
repositories, try `make released-only` or `make nodejs10`

To configure git repository access, you can use the simple script `update_git`
in the main directory of this repository. The assumed directory structure is,

    (cwd)
      \--- nodejs-packaging
      \--- node

where `node` is the clone of https://github.com/nodejs/node.git and `nodejs-packaging`
is the clone of this repository. `(cwd)` is the parent directory and the
current working directory. Then the workflow is simply to run `nodejs-packaging/update_git`
that will fetch new node changes and setup all the `vX.Y-staging` branches.

Dependencies you need installed are:
* obs-service-obs_scm
* obs-service-set_version
* obs-service-tar_scm
* obs-service-recompress

You can find these in the `openSUSE:Tools` project on https://build.opensuse.org



How to update a version
-----------------------

First, check if upstream has version updated by running,

    ./check_versions.sh

If you wish to update `nodeX` version only, then run

    ./check_versions.sh -u nodeX

This will update the OBS package with the new upstream version. To update
the changelog,

    cd nodeX
    osc vc
    cd ..

And now check if patches apply,

    make clean
    make nodeX

If everything applies, you are good to go. If you need to refresh patches,
you can do so in

    cd devel:languages:nodejs/nodeX
    [ fix the patches ]


Then don't forget to copy the fixed patches back to `nodeX` directory of the
nodejs-packaging folder.

*NOTE*: Same patches can be symlinked together. To find which other patches are pointing
to modified patch (before you overwrite it ;), use the `find_links` script

    ./find_links nodeX/patch_file.patch

And this will display if this is a link, a file and whether other things point to it.
If this is a link, you can break it (delete it and copy the original file there) or
just run

    ./find_links -b nodeX/patch_file.patch


You can find broken links by

    ./find_links -B

Make sure that when you are changing these patches to keep same patches linked so you
do not need to redo the same fix over and over again. The standard way NodeJS migrates
patches is master -> latest staging -> next staging -> etc... You can limit your work
duplication by just migrating the patch changes as upstream changes.

*NOTE*: Some patchse cannot be migrated from one major version to another as they contain
version specific strings. Most notable of these are `node-gyp-addon-gypi.patch` and `versioned.patch`

If you are not sure if you broke some patches by overwriting them, just do

    make clean
    make released-only

if everything applies, it's _probably_ ok.

And don't forget to have lots of fun!

