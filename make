#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8; -*-

shopt -s extglob

OUT_FILE=${OUT_FILE:-argsparse.sh}

(
	cat src/00_head
	for file in src/!(00_head|*~)
	do
		printf '\n\n'
		tail -n +4 < "$file"
	done
) > "$OUT_FILE"

chmod +x "$OUT_FILE"
