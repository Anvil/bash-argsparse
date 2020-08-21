#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8; -*-
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
## @file
## @author Damien Nadé <bash-argsparse@livna.org>
## @brief Bash completion for scripts using argsparse library.
## @copyright WTFPLv2
## @version 1.8
## @details
## @par URL
## https://github.com/Anvil/bash-argsparse @n
##
## @par Purpose
##
## To automatically enable, for bash-completion users, completion for
## scripts that use the argsparse library.
##
## @par Usage
##
## In your ~/.bashrc, add the following lines to enable completion for
## all your argsparse-written scripts:
##
## @code
##     . argsparse-completion.sh
##     complete -F _argsparse_complete [ your scripts names ... ]
## @endcode
##
## @par Required configuration
##
## argsparse-completion relies on a few shell settings:
##
## @li "sourcepath" shell option must be enabled. This should be
##   enabled by default, but you can enforce it by running:
##
## @code
##   shopt -s sourcepath
## @endcode
##
## If correctly enabled, the following command below should return
## this output.
##
## @code
##   $ shopt sourcepath
##   sourcepath      on
## @endcode
##
## @par Limitations
##
## @li Every time the completion is invoked, the completed script will
##   be sourced, up to either the argsparse_parse_options() function
##   call or any the first return top-level statement. This means that
##   up to this point the script should not have any side effect (like
##   file system alteration, network connections, ...), and should
##   avoid time-consuming tasks up to this point.
##
## @li Only a limited set of option types completion are currently
##   implemented.
##
##
##
## @defgroup ArgsparseCompletion Bash Completion-related functions.

## @fn __argsparse_compgen()
## @private
## @brief A compgen wrapper.
## @details This function will just call compgen with given argument,
## safely adding $cur in the command line. Also if compgen_prefix is
## set, a -P option will be provided to compgen.
## @note __argsparse_compgen() makes use of the bash-completion
## standard variables.
## @param param... any set of compgen options
## @return compgen output and return code.
## @ingroup ArgsparseCompletion
__argsparse_compgen() {
	if [[ -v compgen_prefix ]]
	then
		set -- "$@" -P "$compgen_prefix"
	fi
	compgen "$@" -- "$cur"
}

## @fn __argsparse_complete_value()
## @brief Complete the value an option.
## @details Run compgen with values matching given option. If an array
## "option_<optionname>_values" exists, complete with its values. Else
## if option has a type, complete values according to type when
## possible. Else do nothing.
## @note __argsparse_complete_value() makes use of the bash-completion
## standard variables.
## @param option a long option name.
## @ingroup ArgsparseCompletion
__argsparse_complete_value() {
	[[ $# -eq 1 ]] || return 1
	local option=$1
	local array option_type
	local -a values
	if array=$(__argsparse_values_array_identifier "$option")
	then
		# Option accepts an enumeration of values.
		values=( "${!array}" )
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

## @fn __argsparse_complete_get_long()
## @brief Find the option we want to complete.
## @details If given word parameter is a recognized option, print the
## matching long option name. Also if "$cur" should be this option
## value, then return 0.
## @param word any word.
## @param long... a list of long options.
## @return the long option matching given parameter.
## @retval 0 if given word matches an option and if that option
## accepts a value.
## @private
## @ingroup ArgsparseCompletion
__argsparse_complete_get_long() {
	[[ $# -ge 1 ]] || return 1
	local word=$1
	shift
	local -a longs=( "$@" )
	local long
	if [[ $word = -[!-] ]]
	then
		long=$(argsparse_short_to_long "${word#-}") || return
	elif __argsparse_index_of "$word" "${longs[@]}" >/dev/null
	then
		long=${word#--}
	else
		# Unknown option
		return 1
	fi
	printf %s "$long"
	argsparse_has_option_property "$long" value
}

## @fn __argsparse_complete()
## @brief Completion for the command stored in ${words[0]}.
## @details Will load the script to complete, and invoke compgen
## according to context.
## @retval non-zero if completed command cannot be sourced.
## @ingroup ArgsparseCompletion
__argsparse_complete() {
	local script=${words[0]}
	(
		set +o posix
		ARGSPARSE_COMPLETION_MODE=1
		shopt -s expand_aliases
		unalias -a
		. "$script" 2>/dev/null || return
		longs=( "${!__argsparse_options_descriptions[@]}" )
		longs=( "${longs[@]/#/--}" )
		option=${prev#--}
		if __argsparse_index_of -- "${words[@]:0:${#words[@]}-1}" >/dev/null
		then
			# We're after the -- parameter, complete positionnal arguments
			__argsparse_compgen -A file
		elif long=$(__argsparse_complete_get_long "$prev" "${longs[@]}")
		then
			# We're right after an option that accepts a value, so
			# complete a value.
			__argsparse_complete_value "$long"
		else
			# Complete current token
			case "$cur" in
				--?*=*|-[!-]?*)
					# Complete the --foo=something pattern as if
					# prev=--foo and cur=something
					# Complete -fsomething as if prev=-f and cur=something
					if [[ "$cur" =~ ^((--[^=]+)=)(.*)$ ||
						"$cur" =~ ^((-[^-]))(.*)$ ]]
					then
						compgen_prefix=${BASH_REMATCH[1]}
						option=${BASH_REMATCH[2]}
						cur=${BASH_REMATCH[3]}
						long=$(__argsparse_complete_get_long \
								"$option" "${longs[@]}") && \
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

## @fn _argsparse_complete()
## @brief The argsparse completion function.
## @details To enable completion on a script that uses the argsparse
## library, call the "complete" built-in as following: @n
## @code
##     complete -F _argsparse_complete <your script>
## @endcode
## @note Technically, this function gets a parameter (the name of the
## command to complete), but it is ignored.
## @ingroup ArgsparseCompletion
_argsparse_complete() {
	local cur prev words cword split
	_init_completion -s || return
	COMPREPLY=(	$(__argsparse_complete) )
}
