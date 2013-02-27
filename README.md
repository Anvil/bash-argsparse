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


### Testing

Here are the topics covered by scripts in tutorial directory:
* 1-basics: Bash Argsparse basics
* 2-values: Options accepting values
* 3-types: Type-checking
* 4-custom-types: User-defined types
* 5-properties: Option properties
* 6-value-checking: Advanced value checking using argsparse
* 7-setting-hook: Changing the way options are set
* 8-misc: Other misc argsparse features.

Invoke each script without parameter or with --help to obtain usage message.
