bash-argsparse
==============

An high level argument parsing library for bash.

Inspired, by the python argparse module, bash-argsparse purpose is to
replace the option-parsing and usage-describing functions commonly
rewritten in all scripts.

This library is implemented for GNU bash version >= 4.2. Prior
versions of bash will fail at interpreting that code.


### Online documentation

Doxygen documentation is available online
[here](http://argsparse.livna.org/doxygen/1.8/).


### Tarballs

Though Bash Argsparse is hosted at
[github](https://github.com/Anvil/bash-argsparse), you can download
tarballs at the following URL:
[http://argsparse.livna.org/](http://argsparse.livna.org/)

### RPMS

Though you can build your own package using the provided spec file, a
bash-argsparse package is currently available in fedora repositories,
for all releases from fedora 19 to rawhide. Ditto for RHEL/Centos 6 &
7, through the EPEL repository.

### Features

The argsparse library offers to script developpers the following features:

* Automatic help message generation
* Simple option declarations
* Different option types: simple, with value, with cumulative (uniq or
  not) values
* User-input checkings (either by type, enumerations or custom checking)
* Hook settings
* Option properties making them excluding each other, aliasing other
  options, or (sic) non-optional.
* Automatic bash completion generation.


### Requirements, Bash settings

A basic argsparse run requires no external commands except the
quite-common "getopt" command. Some argsparse-built-in type checkings
may require some other (like "host" and "getent") but you do not have
to use those types.

Argsparse relies on a lot of bash built-in commands ("printf", "[",
"read", ...) and internal features such as arrays, associative arrays,
extended (ksh-like) globbing. That's why the "extglob" shell option is
automatically enabled and posix-mode is automatically disabled when
loading the argsparse library.

The code has been tested on bash 4.1, 4.2 and 4.3 and is definitely
not POSIX-compliant.

Compliance with the "nounset" and "failglob" bash settings is
supported.

Content
-------

* argsparse.sh: the library.
* tutorial: a bunch of small demonstration scripts for new users.
* bash-argsparse.spec: a spec file to build RPM packages.
* debian: the directory required to build deb packages.
* Doxyfile: doxygen configuration file.
* doxygen-bash.sed:
  [bash-doxygen](https://github.com/Anvil/bash-doxygen) doxygen input
  filter.
* unittest: a test script to validate most of argsparse features.

### Testing

Here are the topics covered by scripts in tutorial directory:
* 0-completion: An automatic bash completion demo for all other
  tutorial scripts. This script will spawn a preconfigured interactive
  bash.
* 1-basics: Bash Argsparse basics
* 2-values: Options accepting values
* 3-cumulative-options: How to keep all user-given values
* 4-types: Type-checking
* 5-custom-types: User-defined types
* 6-properties: Option properties
* 7-value-checking: Advanced value checking using argsparse
* 8-setting-hook: Changing the way options are set
* 9-misc: Other misc argsparse features.

Invoke each script without parameter or with --help to obtain usage message.

Known limitations (or bugs)
---------------------------

* You cannot have a short option without a long option.
* Too few verifications about property values are made.
* Compliance with errexit is not supported (yet).
* Compliance with Non-bind versions of the "host" command has not been
  tested.
