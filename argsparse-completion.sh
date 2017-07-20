#!/bin/bash
# -*- tab-width: 4; encoding: utf-8; -*-
#
## @file
## @author Damien Nadé <bash-argsparse@livna.org>
## @brief ...
## @copyright WTFPLv2
## @version 1.7
#
#########
# License:
#
#             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
# Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
#
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#
#########
#

__argsparse_complete() {
	local script=$1
	(
		set +o posix
		ARGSPARSE_COMPLETION_MODE=1
		. "$script" 2>/dev/null
		case "$cur" in
			""|-)
				shorts=( "${!__argsparse_short_options[@]}" )
				shorts=( "${shorts[@]/#/-}" )
				;;&
			""|-*)
				longs=( "${!__argsparse_options_descriptions[@]}" )
				longs=( "${longs[@]/#/--}" )
				printf %s "${shorts[*]} ${longs[*]}"
				;;
			*)
				longs=( "${!__argsparse_options_descriptions[@]}" )
				longs=( "${longs[@]/#/--}" )
				[[ "$prev" = --* ]] || return 0
				option=${prev#--}
				__argsparse_index_of "$prev" "${longs[@]}" >/dev/null || \
					return 0
				if array=$(__argsparse_values_array_identifier "$option")
				then
				  	values=( ${!array} )
					printf %s "${values[*]}"
				fi
				;;
		esac
	)
}

_argsparse_complete() {
	local cur prev words cword split
	_init_completion -s || return
	local argsparse_complete=$(__argsparse_complete "${words[0]}")
	COMPREPLY=(	$(compgen -W "$argsparse_complete" -- "$cur" ) )
}

complete -F _argsparse_complete 1-basics 2-values 3-cumulative-options 4-types 5-custom-types 6-properties 7-value-checking 8-setting-hook 9-misc

