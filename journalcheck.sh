#!/bin/bash

#  journalcheck - Simple 'logcheck' replacement for journald
#  (C) Alexander Koch

#  This software is released under the terms of the MIT License, see LICENSE.

# to have filters work in foreign languages (french)
export LANG=POSIX

FILTERS_GLOBAL=${JC_FILTERS_GLOBAL:-"/usr/lib/journalcheck"}
FILTERS_LOCAL=${JC_FILTERS_USER:-~/".journalcheck.d"}
CURSOR_FILE=${JC_CURSOR_FILE:-~/".journalcheck.cursor"}
NUM_THREADS=${JC_NUM_THREADS:-$(grep -c '^processor' "/proc/cpuinfo")}
LOGLEVEL=${JC_LOGLEVEL:-"0..5"}

FILTER_FILE="$(mktemp)"
LOG="$(mktemp)"


function cleanup() {
	rm -f "$FILTER_FILE" "$LOG" "${LOG}_???"
}
trap cleanup EXIT

# merge filters to single file
cat "$FILTERS_GLOBAL"/*.ignore > "$FILTER_FILE"
if [ -d "$FILTERS_LOCAL" ]; then
	cat "$FILTERS_LOCAL"/*.ignore >> "$FILTER_FILE" 2>/dev/null
fi

# fetch journal entries since last run (or system bootup)
ARGS="--no-pager --show-cursor -l -p $LOGLEVEL"
if [ -r "$CURSOR_FILE" ]; then
	ARGS+=" --after-cursor=$(cat "$CURSOR_FILE")"
else
	ARGS+=" -b"
fi
journalctl $ARGS &> "$LOG"
if [ $? -ne 0 ]; then
	echo "Error: failed to dump system journal" >&2
	exit 1
fi

# save cursor for next iteration
CURSOR="$(tail -n 1 "$LOG")"
if [[ $CURSOR =~ ^--\ cursor:\  ]]; then
	echo "${CURSOR:11}" > "$CURSOR_FILE"
elif [[ $CURSOR =~ ^--\ No\ entries\ --$ ]]; then
	exit 0
else
	echo "Error: unable to save journal cursor" >&2
fi

# split journal into NUM_THREADS parts, spawn worker for each part
split -a 3 -n l/$NUM_THREADS -d "$LOG" "${LOG}_"
for I in $(seq 0 $(($NUM_THREADS - 1))); do
	F="${LOG}_$(printf "%03d" "$I")"
	{ grep -Evf "$FILTER_FILE" "$F" > "${F}_"; mv "${F}_" "$F"; } &
done

# wait for all worker threads to finish
wait

# re-assemble filtered output to stdout, remove parts
for I in $(seq 0 $(($NUM_THREADS - 1))); do
	cat "${LOG}_$(printf "%03d" "$I")"
done

exit 0
