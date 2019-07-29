Overview
--------

Very simple templates for NodeJS packages in OpenSUSE.

For any particular version of NodeJS, like 12 or 6 (henceforth
referred to as X), the following work flow follows,

1. NodeJS package nodeN is checkout from the main project
2. Files in the common/ directory are copied directly to the package
3. Files in the N/ directory are copied to the package
4. `nodejsN.spec` file is generated using `sed` with help of
   `nodejs.spec.in` and `nodejsN.sed` script and copied to the package file.

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
versions.

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

