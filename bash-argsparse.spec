Summary: An high level argument parsing library for bash
Name: bash-argsparse
Version: 1.8
Release: 1%{?dist}
License: WTFPL
URL: https://github.com/Anvil/bash-argsparse
Source0: http://argsparse.livna.org/%{name}-%{version}.tar.gz
BuildArch: noarch
# Binaries are required for unittest to perform cleanly.
BuildRequires: doxygen glibc-common util-linux /usr/bin/host

Requires: bash >= 4.2
Requires: util-linux glibc-common /usr/bin/host

%description
An high level argument parsing library for bash.

The purpose is to replace the option-parsing and usage-describing
functions commonly rewritten in all scripts.

This library is implemented for bash version 4. Prior versions of bash
will fail at interpreting that code.

%prep
%setup -q

%build
# Nothing to build, except the documentation.
doxygen

%install
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
for file in argsparse argsparse-completion; do
    install -m 0755 "$file.sh" $RPM_BUILD_ROOT/%{_bindir}
    ln -s "$file".sh $RPM_BUILD_ROOT/%{_bindir}/"$file"

%check
./unittest

%files
%doc tutorial README.md html COPYING
%{_bindir}/argsparse*


%changelog
* Tue Sep  5 2017 Dams <bash-argsparse[AT]livna.org> - 1.8-1
- Version 1.8

* Thu Mar 5 2015 Dams <bash-argsparse[AT]livna.org> - 1.7-1
- Version 1.7

* Wed Jan 28 2015 Dams <bash-argsparse[AT]livna.org> - 1.6.2-1
- Version 1.6.2
- Dropped fedora patch (included upstream)

* Fri Oct 24 2014 Dams <bash-argsparse[AT]livna.org> - 1.6.1-3
- Using package names instead of path for Requires/BuildRequires

* Wed Oct 15 2014 Dams <bash-argsparse[AT]livna.org> - 1.6.1-2
- Added patch to fix some unittest issues

* Thu Oct 9 2014 Dams <bash-argsparse[AT]livna.org> - 1.6.1-1
- Version 1.6.1
- Fixed changelog names

* Thu Oct 9 2014 Dams <bash-argsparse[AT]livna.org> - 1.6-4
- Update host path in *Requires tags.

* Wed Oct 8 2014 Dams <bash-argsparse[AT]livna.org> - 1.6-3
- Added more BuildRequires to allow unittest script to run correctly
  restricted small environments

* Mon Sep 15 2014 Dams <bash-argsparse[AT]livna.org> - 1.6-2
- Fixed date in changelog entry

* Tue Aug 12 2014 Dams <bash-argsparse[AT]livna.org> - 1.6-1
- License tag is now WTFPL
- Removed trailing dot at the end of Summary
- Removed BuildRoot tag
- Requiring commands instead of packages

* Mon Jan 13 2014 Dams <bash-argsparse[AT]livna.org> - 1.6-0
- Version 1.6
- Added doxygen documentation
- check section

* Thu Mar 21 2013 Dams <bash-argsparse[AT]livna.org> - 1.5-0
- Version 1.5
- Updated Requires
- Removed old/fedora-obsolete directives/noise

* Thu Mar 14 2013 Dams <bash-argsparse[AT]livna.org> - 1.4-0
- Initial build.
