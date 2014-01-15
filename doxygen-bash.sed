#!/bin/sed -nf
/^## \+@fn/{
    :step
    /@param [^ ]\+ .*$/{
        s/\(@fn [^(]*\)(\(.*\))\(.*\)\(@param \)\([^ \n]\+\(\.\.\.\)\?\)\([^\n]*\)$/\1(\2, \5)\3\4\5\7/
    }
    /[a-zA-Z0-9_]\+() {$/!{
         N
	 b step
    }
    s/\(@fn[^(]\+\)(, /\1(/
    s/\(@fn \([^(]\+\)(\)\([^)]*\)\().*\)\n\2() {/\1\3\4\n\2(\3) { }/
    s/\(^\|\n\)## /\1\/\/! /g
    p
}
s/^declare -a \([^=]\+\).*$/Array \1;/p
s/^declare -A \([^=]\+\).*$/AssociativeArray \1;/p
s/^declare -r \([^=]\+\)=\(.*\)$/ReadOnly String \1 = \2;/p
s/^declare -i \(.\+\)$/Integer \1;/p
s/^declare \([^-].*\)$/String \1;/p
s/^## /\/\/! /p
