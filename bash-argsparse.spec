Summary: An high level argument parsing library for bash.
Name: bash-argsparse
Version: 1.5
Release: 0%{?dist}
License: WTFPL
URL: https://github.com/Anvil/bash-argsparse
Source0: https://github.com/Anvil/bash-argsparse/archive/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch: noarch
Requires: bash >= 4.1

%description
An high level argument parsing library for bash.

The purpose is to replace the option-parsing and usage-describing
functions commonly rewritten in all scripts.

This library is implemented for bash version 4. Prior versions of bash
will fail at interpreting that code.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
install -m 0755 argsparse.sh $RPM_BUILD_ROOT/%{_bindir}

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc tutorial
%{_bindir}/argsparse.sh


%changelog
* Thu Mar 14 2013 Dams <anvil[AT]livna.org> - 1.4-0
- Initial build.

