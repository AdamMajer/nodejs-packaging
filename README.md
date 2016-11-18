Very simple templates for NodeJS packages in OpenSUSE.

For any particular version of NodeJS, like 4 or 6 (henceforth
referred to as X), the following work flow follows,

1. NodeJS package nodeN is checkout from the main project
2. Files in the common/ directory are copied directly to the package
3. Files in the N/ directory are copied to the package
4. `nodejsN.spec` file is generated using `sed` with help of
   `nodejs.spec.in` and `nodejsN.sed` script and copied to the package file.

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

