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

__argsparse_complete_printf() {
	printf -- '%s\n%s' "$@"
}

__argsparse_complete_value() {
	local option=$1
	local array option_type
	local values
	if array=$(__argsparse_values_array_identifier "$option")
	then
		values=( ${!array} )
		printf '%s\n%s' -W "${values[*]}"
	elif option_type=$(argsparse_has_option_property "$option" type)
	then
		case "$option_type" in
			file|pipe|socket|link)
				printf -- '%s\n%s' -A file
				;;
			directory|group)
				printf -- '%s\n%s' -A "$option_type"
				;;
			username)
				printf -- '%s\n%s' -A user
				;;
			host|hostname)
				printf -- '%s\n%s' -A hostname
				;;
			hexa)
				values=( "$cur"{a..f} )
				;;&
			int|hexa)
				values+=( "$cur"{0..9} )
				printf -- '%s\n%s' -W "${values[*]}"
				;;
		esac
	fi
}

__argsparse_complete() {
	local script=$1
	(
		set +o posix
		ARGSPARSE_COMPLETION_MODE=1
		. "$script" 2>/dev/null
		longs=( "${!__argsparse_options_descriptions[@]}" )
		longs=( "${longs[@]/#/--}" )
		option=${prev#--}
		if __argsparse_index_of "$prev" "${longs[@]}" >/dev/null && \
			  argsparse_has_option_property "$option" value
		then
			__argsparse_complete_value "$option"
		else
			case "$cur" in
				""|-)
					shorts=( "${!__argsparse_short_options[@]}" )
					shorts=( "${shorts[@]/#/-}" )
					;;&
				""|-*)
					printf -- '%s\n%s' -W "${shorts[*]} ${longs[*]}"
					;;
				*)
					;;
			esac
		fi
	)
}

_argsparse_complete() {
	local cur prev words cword split
	_init_completion -s || return
	local complete_type complete_values
	{ read complete_type ; complete_values=$(< /dev/stdin) ;} \
	  < <(__argsparse_complete "${words[0]}")
	COMPREPLY=(	$(compgen "$complete_type" "$complete_values" -- "$cur" ) )
}

complete -F _argsparse_complete 1-basics 2-values 3-cumulative-options 4-types 5-custom-types 6-properties 7-value-checking 8-setting-hook 9-misc

