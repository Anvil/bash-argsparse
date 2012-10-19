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
* argsparse-test: a small demonstration script.


### Testing


Try using the argsparse-test script.

* Invoking it without any parameter will trigger the usage function :

  $ argsparse-test

* Try adding some options. Check argsparse-test source code for hints.
