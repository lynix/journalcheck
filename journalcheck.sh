#!/bin/bash

#  journalcheck - Simple 'logcheck' replacement for journald
#  (C) 2015-2019 Alexander Koch

#  This software is released under the terms of the MIT License, see LICENSE.


FILTERS_GLOBAL=${JC_FILTERS_GLOBAL:-"/usr/lib/journalcheck"}
FILTERS_LOCAL=${JC_FILTERS_USER:-~/".journalcheck.d"}
STATE_FILE=${JC_STATE_FILE:-~/".journalcheck.state"}
NUM_THREADS=${JC_NUM_THREADS:-$(grep -c '^processor' "/proc/cpuinfo")}
LOGLEVEL=${JC_LOGLEVEL:-"0..5"}


# merge filters to single file
FILTER_FILE="$(mktemp)"
cat "$FILTERS_GLOBAL"/*.ignore > "$FILTER_FILE"
if [ -d "$FILTERS_LOCAL" ]; then
	for F in "$FILTERS_LOCAL"/*.ignore; do
		[ -r "$F" ] && cat "$F" >> "$FILTER_FILE"
	done
fi

# fetch journal entries since last run (or beginning of journal)
LOG="$(mktemp)"
if [ -r "$STATE_FILE" ]; then
	journalctl --no-pager -l -p "$LOGLEVEL" --since="$(cat "$STATE_FILE")" > "$LOG"
else
	journalctl --no-pager -l -p "$LOGLEVEL" -b > "$LOG"
fi
date +'%F %T' > "$STATE_FILE"

# split journal into NUM_THREADS parts, spawn worker for each part
split -a 3 -n l/$NUM_THREADS -d "$LOG" "${LOG}_"
for I in $(seq 0 $(($NUM_THREADS - 1))); do
	IN="${LOG}_$(printf "%03d" "$I")"
	OUT="${LOG}_${I}_filtered"
	{ egrep -vf "$FILTER_FILE" "$IN" > "$OUT"; rm "$IN"; } &
done

# wait for all worker threads to finish
wait

# re-assemble filtered output to stdout, remove parts
for I in $(seq 0 $(($NUM_THREADS - 1))); do
	cat "${LOG}_${I}_filtered"
	rm "${LOG}_${I}_filtered"
done

rm -f "$FILTER_FILE" "$LOG"

exit 0
