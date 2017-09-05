#!/bin/sed -nf
##
##             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
##                     Version 2, December 2004
##
##  Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
##
##  Everyone is permitted to copy and distribute verbatim or modified
##  copies of this license document, and changing it is allowed as long
##  as the name is changed.
##
##             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
##    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
##
##   0. You just DO WHAT THE FUCK YOU WANT TO.
##
##
## Project Home Page: http://github.com/Anvil/bash-doxygen/
## Project Author: Damien Nadé <github@livna.org>
##

/^## \+@fn/{
    :step
    /@param [^ ]\+ .*$/{
        # Groups are
        # \1: @fn <funcname>
        # \2: already identified params
        # \3: previous doc string
        # \4: @param<space>
        # \5: newly identified param name plus optional dot-dot-dot string
        # \6: optional dot-dot-dot string
        # \7: everything after \5 to end of line
        # Here, we-reinsert param names into the <funcname>()
        s/\(@fn [^(\n]\+\)(\([^(]*\))\(.*\)\(@param \)\([^ \n]\+\(\.\.\.\)\?\)\([^\n]*\)$/\1(\2, \5)\3\4\5\7/
    }
    / *\(function \+\)\?[a-z:.A-Z0-9_]\+ *() *{ *$/!{
        N
        b step
    }
    # Remove optional 'function' keyword (and some extra spaces).
    s/ *\(function \+\)\?\([a-z:.A-Z0-9_]\+ *() *{\) *$/\2/
    # Here, we should have @fn (, param1, param2, param3), we remove
    # the first extra ", ".
    s/\(@fn[^(]\+\)(, /\1(/
    # Remove the function body to avoid interference, and re-introduce
    # list of parameters in the funcname(<here>).
    s/\(@fn \([^(]\+\)(\)\([^)]*\)\().*\)\n\2() *{/\1\3\4\n\2(\3) { }/
    # Replace all '## ' by '//! ' at beginning-of-line.
    s/\(^\|\n\)##\n/\1\/\/!\n/g
    s/\(^\|\n\)## /\1\/\/! /g
    p
    b end
}

/^declare /{
    # The principle is quite easy. For every declare option, we add a
    # keyword into the sed exchange buffer. Once everything is parsed,
    # we add the variable identifier and maybe the variable default
    # value, add that to the exchange buffer and print the result.

    # Reset exchange buffer
    x
    s/.*//
    x
    # Remove declare keyword, we wont need it anymore
    s/^declare \+//
    # Simple declaration case.
    /^[^-]/{
        x
        s/.*/&String /
        x
        b declareprint
    }
    # Concat options. Some of them are ignored, such as -f.
    :declare
    s/^-\([aAilrtux]\+\) \+-\([aAilrtux]\+\) \+/-\1\2 /
    t declare

    # Prepend Exported and ReadOnly attributes
    /^-[aAiltur]*x/{
        x
        s/.*/&Exported /
        x
    }
    /^-[aAiltux]*r/{
        x
        s/.*/&ReadOnly /
        x
    }

    # Integer type, exclusive with default 'String' type.
    /^-[aAlturx]*i/{
        x
        s/.*/&Integer /
        x
        b array
    }

    # String type. handling.
    /^-[aAtrx]*l/{
        x
        s/.*/&LowerCase /
        x
    }
    /^-[aAtrx]*u/{
        x
        s/.*/&UpperCase /
        x
    }
    x
    s/.*/&String /
    x

    : array
    # For arrays, we remove the initialisation since I dont know yet
    # how to print it for doxygen to understand.
    /^-[Ailturx]*a/{
        x
        s/.*/&Array /
        x
        b deletevalue
    }
    /^-[ailturx]*A/{
        x
        s/.*/&AssociativeArray /
        x
        b deletevalue
    }

    :declareprint
    # Remove the declare option, x, then G will concat the exchange
    # buffer (the 'type' string) and the regular buffer (the var
    # possibly followed by an init value). The rest is quite easy to
    # understand.
    s/-[^ ]\+ \+//
    x
    G
    s/\n//
    s/=/ = /
    s/$/;/
    p
    x
    b end
}

/^ *export \+[_a-zA-Z]/{
    s/=/ = /
    s/\([^;]\) *$/\1;/
    s/^ *export \+/Exported String /
    p
    b end
}


# Delete non doxygen-related lines content, but not the line
# themselves.
/^## \|^##$/!{
     s/^.*$//p
}
b end

# For arrays, to avoid duplication.
: deletevalue
s/\(-[^ ]\+ \+[^=]\+\)=.*/\1/
b declareprint

:end
# Make all ## lines doxygen-able.
s/^##\( \|$\)/\/\/!\1/p
