bash-argsparse
==============

An high level argument parsing library for bash.

The purpose is to replace the option-parsing and usage-describing
functions commonly rewritten in all scripts.

This library is implemented for bash version 4. Prior versions of
bash will fail at interpreting that code.


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
