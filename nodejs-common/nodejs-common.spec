#
# spec file for package nodejs-common
#
# Copyright (c) 2017 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

###########################################################
#
#   WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!
#
# This spec file is generated from a template hosted at
# https://github.com/AdamMajer/nodejs-packaging
#
###########################################################

Name:           nodejs-common
Version:        2.0
Release:        0
License:        MIT
Summary:        Common files for the NodeJS ecosystem
Url:            https://github.com/AdamMajer/nodejs-packaging
Group:          Development/Languages/NodeJS
Source1:        node
Source2:        LICENSE
Requires:       nodejs
Conflicts:      nodejs4 < 4.8.4
Conflicts:      nodejs6 < 6.11.1
Conflicts:      nodejs7 < 7.10.1
Conflicts:      nodejs8 < 8.1.4

BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Common NodeJS files that allow recursive invocation of Node executable
while retaining the same codestream version.

%prep
%build
cp %{S:2} .
%install
install -D -m 0755 %{S:1} %{buildroot}%{_bindir}/node
ln -s node %{buildroot}%{_bindir}/npm
ln -s node %{buildroot}%{_bindir}/npx

%files
%defattr(-,root,root)
%{_bindir}/node
%{_bindir}/npm
%{_bindir}/npx
%license LICENSE

%changelog

