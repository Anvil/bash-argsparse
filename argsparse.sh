#!/bin/bash
#
# Author: Damien Nadé <bash-argsparse@livna.org>
# URL: https://github.com/Anvil/bash-argsparse
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
# Description and purpose:
#
# To replace the option-parsing and usage-describing functions
# commonly rewritten in all scripts.
#
# This library is implemented for bash version 4. Prior versions of
# bash will fail at interpreting that code.
#
##
#
# Use the argsparse_use_option function to declare your options with
# their single letter counterparts, along with the description.
#
# The argsparse_use_option syntax is:
#
#     argsparse_use_option "optstring" "option description string" \
#		"property1" "property2" "optional default value"
#
# An "optstring" is of the form "som=estring:". This would declare a
# long option named somestring. The ending ':' is optional and means,
# if present, means the long option expects a value on the command
# line. The '=' char is also optional and means the following letter
# is the short single-letter equivalent option of --something.
#
##
#
# Options may have properties. 
# The currently supported properties are:
#
# * "hidden"
# 	An hidden option will not be shown in usage.
#
# * "mandatory"
#	An option marked as mandatory is required on the command line. If
#	a mandatory option is omited by the user, usage will be triggered
#	by argsparse_parse_options.
#
# * "value"
#	Same effect if you end your optstring with a ":" char.
#
# * "short"
#   To be described...
#
##
#
# After the options are declared, invoke the function
# argsparse_parse_options with the all script parameters. This will
# define:
#
# * program_params, an array, containing all non-option parameters.
#
# * program_options, an associative array. For each record of the
#   array:
#   * The key is long option name.
#   * And about values:
#
#     * If option doesn't expect a value on the command line, the
#       value represents how many times the option has been
#       found on the command line
#
#     * If option does require a value, the array record value is the
#       value of the last occurence of the option found on the command
#       line.
#
##
#
# If a 'usage' function is defined, and shall parse_option return with
# non-zero status, 'usage' will be automatically called.
#
# This file automatically defines a default 'usage' function, which
# may be removed or overridden by the program.
#
##
#
# During option parsing, for every long option of the form
# '--longoption' expecting a value:
# 
# * If it exists an array named 'option_longoption_values' and the
#   user-given value doesn't belong to that array, then the
#   argsparse_parse_options function immediately returns with non-zero
#   status, triggering 'usage'.
#
# * If it doesn't exist an array named 'option_longoption_values' and
#   if a function named 'check_value_of_longtoption' exist, this
#   function is called with the user-given value as its first
#   positionnal parameter. If check_value_of_longtoption returns with
#   non-zero status, then parse_option immediately returns with
#   non-zero status, triggering 'usage'.
#
# Also, still during option parsing and for *every* long option of the
# form '--longoption':
#
# * After value-checking, if a function named 'set_option_longoption'
#   exists, then, instead of modifying the 'program_options'
#   associative array, this function is automatically called with
#   'longoption' as its first positionnal parameter, and, if
#   'longoption' expected a value, the value is given as the function
#   second positionnal parameter.
#
# Known limitations and bugs:
# * You cannot have a short option without a long option.
# * Non-alphanumeric, non-underscore chars in option names
#   could and will lead to trouble and failure.
# * No verification is made to prevent 2 long options to have the same
#   short option. If that happens, result only depends of bash inner
#   magic.
#

# We're not compatible with older bash versions.
if [[ "$BASH_VERSINFO" -lt 4 ]]
then
	printf "This requires bash >= 4 to run.\n"
	return 1 2>/dev/null 
	exit 1
fi

ARGSPARSE_INTERNAL_VERSION=1.0

# This is an associative array. It should contains records of the form
# "something" -> "Some usage descrition string".
# The "something" string is referred as the "optstring" later in
# source code and comments.
# * If the --something option expects a value, then make the optstring
#   ends with a colon char ':'.
# * If the --something option can have a short single-lettered option
#   equivalent like -s, then prefix the letter by an equal '=' char.
typeset -A __argsparse_options_descriptions=()

# The program name
__argsparse_pgm="${0##*/}"


# The default minimum parameters requirement for command line.
__argsparse_minimum_parameters=0

argsparse_minimum_parameters() {
	# Set the minimum number of non-option parameters expected on the
	# command line. (the __argsparse_minimum_parameters value)
	# @param a positive number.
	[[ $# -ne 1 ]] && return 1
	local min=$1
	[[ "$min" != +([0-9]) ]] && return 1
	__argsparse_minimum_parameters=$min
}


# 2 generic functions
__argsparse_index_of() {
    # Verifies if a key belongs to an array
    # 1st Parameter: a key
    # other parameters: arrays keys
    # returns 0 if first parameters is amongst other parameters and
    # prints the found index.
    # Else doesnt print anything and returns 1
    [ $# -lt 2 ] && return 1
    local key=$1 ; shift
    local index=0
    local elem

    for elem in "$@"
    do
      [ "$key" != "$elem" ] && : $((index++)) && continue
      echo $index
      return 0
    done

    return 1
}

__argsparse_join_array() {
       # Like the 'join' string method in python, join multiple
       # strings by a char.
       # @param a single char
       # @param multiple string.
       local IFS="$1$IFS"
       shift
       printf "%s" "$*"
}

argsparse_option_to_identifier() {
	local option=$1
	printf "%s" "${option//-/_}"
}

# Following functions define the default option-setting hook and its
# with/without value counter-parts. They can be referered in external
# source code, though they should only be in user-defined
# option-setting hooks.

# All user-defined option-setting hook should be defined like
# argsparse_set_option

argsparse_set_option_without_value() {
	# The default action to take for options without values.
	# @param a long option name
	[ $# -ne 1 ] && return 1
	local option=$1
	: $((program_options["$option"]++))
}

argsparse_set_option_with_value() {
	# The default action to take for option with values. 
	# @param a long option name
	# @param the value put on command line for given option.
	[ $# -ne 2 ] && return 1
	local option=$1
	local value=$2
	program_options["$option"]=$value
}

argsparse_set_option() {
	# This function is the default option-setting hook.
	[[ $# -ne 2 && $# -ne 1 ]] && return 1
	local option=$1
	[[ $# -eq 2 ]] && local value=$2

	if argsparse_has_option_property "$option" value
	then
		argsparse_set_option_with_value "$option" "$value"
	else
		argsparse_set_option_without_value "$option"
	fi
}


# A generic usage function.

set_option_help() {
	# This is the default hook for the --help option.
	usage
}

_usage_short() {
	local optstring long values
	printf "%s " "$__argsparse_pgm"
	for long in "${!__argsparse_options_descriptions[@]}"
	do
		if argsparse_has_option_property "$long" hidden 
		then
			continue
		fi
		argsparse_has_option_property "$long" mandatory || printf "[ "
		printf -- "--%s " "$long"
		if argsparse_has_option_property "$long" value
		then
			if __argsparse_option_has_declared_values "$long"
			then
				values="option_${long}_values[@]"
				printf "<%s> " "$(__argsparse_join_array "|" "${!values}")"
			else
				printf "arg "
			fi
		fi
		argsparse_has_option_property "$long" mandatory || printf "] "
	done
	printf "\n"
}

_usage_long() {
	local long short sep format
	local -A long_to_short=()
	for short in "${!__argsparse_short_options[@]}"
	do
		long=${__argsparse_short_options["$short"]}
		long_to_short["$long"]=$short
	done
	for long in "${!__argsparse_options_descriptions[@]}"
	do
		if argsparse_has_option_property "$long" hidden 
		then
			continue
		fi
		# Pretty printer issue here. If the long option length is
		# greater than 8, we just use next line to print the option
		# description.
		if [[ "${#long}" -le 8 ]]
		then
			sep='\t'
		else
			sep='\n\t\t\t'
		fi
		# Define format according to the presence of the short option.
		short=${long_to_short["$long"]}
		if [[ -n "$short" ]]
		then
		    format="\t-%s | --%s$sep%s\n"
		else
		    format="\t%s     --%s$sep%s\n"
		fi
		printf "$format" "$short" "$long" \
			"${__argsparse_options_descriptions["$long"]}"
	done
}

usage() {
	# This is a generic help message generated by the optstring and
	# their descriptions.
	# There's a lot of room for improvement here.
	_usage_short
	printf "\n"
	# This will print option descriptions.
	_usage_long
	[[ -n "$argsparse_usage_description" ]] && \
		printf "\n%s\n" "$argsparse_usage_description"
	exit 1
}


# 

__argsparse_option_has_declared_values() {
	local option=$1
	local identifier="$(argsparse_option_to_identifier "$option")"
	local possible_values="option_${identifier}_values"
	[[ "$(declare -p "$possible_values" 2>/dev/null)" = \
		"declare -"[aZ]" $possible_values='("* ]]
}

__argsparse_check_missing_options() {
	local option count=0
	for option in "${!__argsparse_options_descriptions[@]}"
	do
		argsparse_has_option_property "$option" mandatory || continue
		# If option has been given, just iterate.
		__argsparse_index_of "$option" "$@" >/dev/null && continue
		printf "%s: --%s: option is mandatory.\n" \
			"$__argsparse_pgm" "$option"
		: $((count++))
	done
	[[ $count -eq 0 ]]
}

argsparse_parse_options() {
	# This function will make option parsing happen, and if an error
	# is detected, the usage function will be invoked, if it has been
	# defined. If it's not defined, the function will return 1.

	# Parse options, and return if everything went fine.
	__argsparse_parse_options_no_usage "$@" && return
	# Something went wrong, invoke usage function, if defined.
	declare -f usage >/dev/null 2>&1 && usage
	return 1
}

__argsparse_parse_options_no_usage() {
	# This function re-set program_params array values. This function
	# will also modify the program_options associative array.
	# If any error happens, this function will return 1.

	# Be careful, the function is (too) big.

	local long short getopt_temp next_param set_hook option_type
	local possible_values next_param_identifier
	local -a longs_array
	# The getopt parameters.
	local longs shorts option

	# No argument sends back to usage, if defined.
	[[ $# -eq 0 ]] && return 1

	# 1. Analyze declared options to create getopt valid arguments.
	for long in "${!__argsparse_options_descriptions[@]}"
	do
		if argsparse_has_option_property "$long" value
		then
			longs_array+=( "$long:" )
		else
			longs_array+=( "$long" )
		fi
	done

	# 2. Create the long options string.
	longs="$(__argsparse_join_array , "${longs_array[@]}")"

	# 3. Create the short option string.
	for short in "${!__argsparse_short_options[@]}"
	do
		if argsparse_has_option_property \
			"${__argsparse_short_options[$short]}" value
		then
			shorts="$shorts$short:"
		else
			shorts="$shorts$short"
		fi
	done

	# 4. Invoke getopt and replace arguments.
	if ! getopt_temp=$(getopt -s bash -n "$__argsparse_pgm" \
		--longoptions="$longs" "$shorts" "$@")
	then
		# Syntax error on the command implies returning with error.
		return 1
	fi
	eval set -- "$getopt_temp"

	# 5. Arguments parsing is really made here.
	while :
	do
		next_param=$1
		shift
		# The regular exit case.
		if [[ "$next_param" = -- ]]
		then
			# Check how many parameters we have and if it's at least
			# what we expects.
			if [[ $# -lt "$__argsparse_minimum_parameters" ]]
			then
				printf \
					"%s: not enough parameters (at least %d expected, %d provided)\n" \
					"$__argsparse_pgm" "$__argsparse_minimum_parameters" $#
					
				return 1
			fi
			# Save program parameters in array
			program_params=( "$@" )
			# If some mandatory option have been omited by the user, then
			# print some error, and invoke usage.
			__argsparse_check_missing_options "${!program_options[@]}"
			return 
		fi
		# If a short option was given, then we first convert it to its
		# matching long name.
		if [[ "$next_param" = -[!-] ]]
		then
			next_param=${next_param#-}
			if [[ -z "${__argsparse_short_options[$next_param]}" ]]
			then
				# Short option without equivalent long. According to
				# current implementation, this should be considered as
				# a bug.
				printf "%s: -%s: option doesnt have any matching long option." \
					"$__argsparse_pgm" "$next_param" >&2
				return 1
			fi
			next_param="${__argsparse_short_options[$next_param]}"
		else
			# Wasnt a short option. Just strip the leading dash.
			next_param="${next_param#--}"
		fi
		# The "identifier string" matching next_param, suitable for
		# variable or function names.
		next_param_identifier="$(argsparse_option_to_identifier "$next_param")"
		# Set option value, if there should be one.
		if argsparse_has_option_property "$next_param" value
		then
			value=$1
			shift
			# Check the value correctness, in case the user has
			# defined a checking hook or a list of acceptable values.
			# (not in that order, though)
			# This may be succeptible to evolution/change.
			possible_values="option_${next_param_identifier}_values"
			if __argsparse_option_has_declared_values "$next_param"
			then
				possible_values="$possible_values[@]"
				if ! __argsparse_index_of "$value" \
					"${!possible_values}" >/dev/null
				then
					printf "%s: %s: Invalid value for %s option.\n" \
						"$__argsparse_pgm" "$value" "$next_param"
					return 1
				fi
			elif option_type=$(argsparse_has_option_property "$next_param" type)
			then
				if ! declare -f "check_option_type_$option_type"
				then
					printf "%s: %s: type has no validation function. This is a bug.\n" \
						"$__argsparse_pgm" "$option_type"
					exit 1
					
				fi
			 	if ! "check_option_type_$option_type" "$value"
				then
					printf "%s: %s: invalid value for %s.\n" \
						"$__argsparse_pgm" "$value" "$next_param"
					return 1
				fi
			elif declare -f "check_value_of_$next_param" >/dev/null 2>&1
			then
				if ! "check_value_of_$next_param" "$value"
				then
					printf "%s: %s: Invalid value for %s option.\n" \
						"$__argsparse_pgm" "$value" "$next_param"
					return 1
				fi
			fi
		else
			unset value
		fi

		# If user has defined a specific setting hook for given the
		# option, then use it, else use default standard
		# option-setting function.
		if declare -f "set_option_$next_param_identifier" >/dev/null 2>&1
		then
			set_hook="set_option_$next_param_identifier"
		else
			set_hook=argsparse_set_option
		fi
		# Invoke setting hook, and if it returns returns some non-zero
		# status, send the user back to usage, if declared, and return
		# with error.
		# The specific $value substitution, here, is to distinguish an
		# empty value from a no-value.
		if ! "$set_hook" "$next_param" ${value+"$value"}
		then
			printf "%s: %s: Invalid value for %s option.\n" \
				"$__argsparse_pgm" "$value" "$next_param"
			return 1
		fi
	done
	return 0
}

# program_options is an associative array containing (if no hook is set)
# 'longoption' -> value, if longoption accepts a value
# or 
# 'longoption' -> how many times the option has been detected on the
# 			      command line.
typeset -A program_options=()

# program_params is a standard array which will contains all
# non-option parameters. (Typically, everything found after the '--')
typeset -a program_params=()

argsparse_reset() {
	program_options=()
	program_params=()
}


# Option properties

typeset -A __argsparse_option_properties=()

argsparse_set_option_property() {
	# Enable a property to a list of options.
	# @param a property name.
	# @params option names.
	[[ $# -lt 2 ]] && return 1
	local property=$1
	shift
	local option p
	for option in "$@"
	do
		p=${__argsparse_option_properties["$option"]}
		__argsparse_option_properties["$option"]="${p:+$p,}$property"
	done
}

argsparse_has_option_property() {
	# Return 0 if property has been set for given option, and print
	# the property value, if available.
	# @param an option name.
	# @param a property name.
	# @return 0 if option has given property.
	[[ $# -ne 2 ]] && return 1
	local option=$1
	local property=$2
	local p=${__argsparse_option_properties["$option"]}
	if ! [[ "$p" =~ (^|.+,)"$property"(:([^,]+))?($|,.+) ]]
	then
		return 1
	fi
	printf %s "${BASH_REMATCH[3]}"
}

# Association short option -> long option.
typeset -A __argsparse_short_options=()

_argsparse_optstring_has_short() {
	# Prints the short option string suitable for getopt command line.
	# Returns non-zero if given optstring doesnt have any short option
	# equivalent.
	local optstring=$1
	if [[ "$optstring" =~ .*=(.).* ]]
	then
		printf "%c" "${BASH_REMATCH[1]}"
		return 0
	fi
	return 1
}

argsparse_use_option() {
	# Define a new optstring.
	# @param an optstring.
	# @param the optstring description, for the usage function.
	# @params an non-ordered list of keywords. Recognized keywords are:
	#   * mandatory: missing option will trigger usage. If a default
	#     value is given, the option is considered as if provided on
	#     the command line.
	#   * hidden: option wont show in default usage function.
	#   * value: option expects a following value.
	#   * short:c: option has a single-lettered (c) equivalent.
	#   * The *last* non-keyword parameter will be considered as the
	#     default value for the option. All other parameters and
	#     values will be ignored.
	[[ $# -ge 2 ]] || return 1
	local optstring=$1
	local description=$2
	shift 2
	local long short
	# configure short option.
	if short=$(_argsparse_optstring_has_short "$optstring")
	then
		set -- "short:$short" "$@"
		optstring=${optstring/=/}
	fi
	# --$optstring expect an argument.
	if [[ "$optstring" = *: ]]
	then
		set -- value "$@"
		long=${optstring%:}
	else
		long=$optstring
	fi

	__argsparse_options_descriptions["$long"]="$description"

	while [[ $# -ne 0 ]]
	do
		case "$1" in
			mandatory|hidden|value|type:*)
				argsparse_set_option_property "$1" "$long"
				;;
			short:?)
				short=${1#short:}
				if [[ -n "${__argsparse_short_options[$short]}" ]]
				then
					printf "%s: %s: short option for %s conflicts with already-configured short option for %s. Aborting.\n" \
						"$__argsparse_pgm" "$short" "$long" \
						"${__argsparse_short_options[$short]}"
					exit 1
				fi
				__argsparse_short_options["$short"]=$long
				;;
			*)
				# The default value
				program_options["$long"]=$1
				;;
		esac
		shift
	done
}

argsparse_is_option_set() {
	# @param an option name
	# @return 0 if given option has been set on the command line.
	[[ $# -ne 1 ]] && return 1
	local option=$1
	__argsparse_index_of "$option" "${!program_options[@]}" >/dev/null
}

# We do define a default --help option.
argsparse_use_option "=help" "Show this help message"
