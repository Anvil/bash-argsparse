Summary: An high level argument parsing library for bash
Name: bash-argsparse
Version: 1.6
Release: 2%{?dist}
License: WTFPL
URL: https://github.com/Anvil/bash-argsparse
Source0: http://argsparse.livna.org/%{name}-%{version}.tar.gz
BuildArch: noarch
# Binaries are required for unittest to perform cleanly.
BuildRequires: doxygen /bin/getopt /bin/getent /bin/host

Requires: bash >= 4.1
Requires: /bin/getopt /bin/getent /bin/host

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
install -m 0755 argsparse.sh $RPM_BUILD_ROOT/%{_bindir}
ln -s argsparse.sh $RPM_BUILD_ROOT/%{_bindir}/argsparse

%check
./unittest

%files
%doc tutorial README.md html COPYING
%{_bindir}/argsparse
%{_bindir}/argsparse.sh


%changelog
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

