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

__argsparse_compgen() {
	if [[ -v compgen_prefix ]]
	then
		set -- "$@" -P "$compgen_prefix"
	fi
	compgen "$@" -- "$cur"
}

__argsparse_complete_value() {
	local option array option_type
	local -a values
	option=$(__argsparse_complete_get_long "$prev" "${longs[@]}") && \
		argsparse_has_option_property "$long" value || return 1
	if array=$(__argsparse_values_array_identifier "$option")
	then
		values=( ${!array} )
		__argsparse_compgen -W "${values[*]}"
	elif option_type=$(argsparse_has_option_property "$option" type)
	then
		case "$option_type" in
			file|pipe|socket|link)
				__argsparse_compgen -A file
				;;
			directory|group)
				__argsparse_compgen -A "$option_type"
				;;
			username)
				__argsparse_compgen -A user
				;;
			host|hostname)
				__argsparse_compgen -A hostname
				;;
			hexa)
				values=( "$cur"{a..f} )
				;;&
			int|hexa)
				values+=( "$cur"{0..9} )
				__argsparse_compgen -W "${values[*]}"
				;;
		esac
	fi
}

__argsparse_complete_get_long() {
	[[ $# -ge 1 ]] || return 1
	local word=$1
	shift
	local -a longs=( "$@" )
	local long
	if [[ $word = -+([!-]) ]] && \
		long=$(argsparse_short_to_long "${word:1:1}") # XXX: change this
	then
		long=$long
	elif __argsparse_index_of "$word" "${longs[@]}" >/dev/null
	then
		long=${word#--}
	else
		return 1
	fi
	printf %s "$long"
	argsparse_has_option_property "$long" value
}

__argsparse_complete() {
	local script=${words[0]}
	(
		set +o posix
		ARGSPARSE_COMPLETION_MODE=1
		. "$script" 2>/dev/null
		longs=( "${!__argsparse_options_descriptions[@]}" )
		longs=( "${longs[@]/#/--}" )
		option=${prev#--}
		if __argsparse_index_of -- "${words[@]:0:${#words[@]}-1}" >/dev/null
		then
			# Complete positionnal arguments
			__argsparse_compgen -A file
		elif long=$(__argsparse_complete_get_long "$prev" "${longs[@]}")
		then
			__argsparse_complete_value "$long"
		else
			case "$cur" in
				--?*=*|-[!-]?*)
					# Complete the --foo=something pattern as if
					# prev=--foo and cur=something
					# Complete -fsomething as if prev=-f and cur=something
					if [[ "$cur" =~ ^((--[^=]+)=)(.*)$ || "$cur" =~ ^((-[^-]))(.*)$ ]]
					then
						compgen_prefix=${BASH_REMATCH[1]}
						option=${BASH_REMATCH[2]}
						cur=${BASH_REMATCH[3]}
						long=$(
							__argsparse_complete_get_long "$option" "${longs[@]}") && \
							__argsparse_complete_value "$long"
					fi
					;;
				""|-)
					shorts=( "${!__argsparse_short_options[@]}" )
					shorts=( "${shorts[@]/#/-}" )
					;;&
				""|-*)
					__argsparse_compgen -W "${shorts[*]} ${longs[*]}"
					;;
				*)
					# Default non-option completion.
					__argsparse_compgen -A file
					;;
			esac
		fi
	)
}

_argsparse_complete() {
	local cur prev words cword split
	_init_completion -s || return
	COMPREPLY=(	$(__argsparse_complete) )
}

complete -F _argsparse_complete 1-basics 2-values 3-cumulative-options 4-types 5-custom-types 6-properties 7-value-checking 8-setting-hook 9-misc

