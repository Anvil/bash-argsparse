bash-argsparse
==============

An high level argument parsing library for bash.

The purpose is to replace the option-parsing and usage-describing
functions commonly rewritten in all scripts.

This library is implemented for bash version 4. Prior versions of
bash will fail at interpreting that code.


### Tarballs

You can download tarballs at:

    http://argsparse.livna.org/

### Features

The argsparse library offers script developpers:

* Automatic help message generation
* Simple option declarations
* Different option types: simple, with value, with cumulative (uniq or
  not) values
* User-input checkings (either by type, enumerations or custom checking)
* Hook settings
* Option properties making them excluding each other, aliasing other
  options, or (sic) non-optional.


### Requirements

The basic features of argsparse requires no external commands except
the quite-common "getopt" command. Some built-in type checkings may
require some other (like "host" and "getent") but you do not have to
use those type.

Argsparse relies on a lot of bash built-in commands ("printf", "[",
"read", ...) and internal features such as arrays, associative arrays,
extended (ksh-like) globbing.

The 'extglob' shell option is automatically enabled when loading
the argsparse library.

The code has been tested on bash 4.1 and 4.2 and is definitely not
POSIX-compliant.

Content
-------

* argsparse.sh: the library.
* tutorial: a bunch of small demonstration scripts for new users.
* bash-argsparse.spec: a spec file to build RPM packages.
* debian: the directory required to build deb packages

### Testing

Here are the topics covered by scripts in tutorial directory:
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
* An option can conflict another ( '-' vs '_' ).
* Compliance against some bash settings like nounset and errexit has
  not (yet) been proved, but is wished.

