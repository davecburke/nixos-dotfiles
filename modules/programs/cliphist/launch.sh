#!/usr/bin/env bash

# Kill existing watchers if any
pkill -f "wl-paste.*cliphist" || true

# Pre-populate static entries if static_entries.txt exists
STATIC_ENTRIES_FILE="$HOME/.config/cliphist/static_entries.txt"
if [ -f "$STATIC_ENTRIES_FILE" ]; then
    while IFS= read -r line; do
        # Skip empty lines
        [ -z "$line" ] && continue
        # Store entry in cliphist (cliphist will handle deduplication)
        echo -n "$line" | cliphist store 2>/dev/null || true
    done < "$STATIC_ENTRIES_FILE"
fi

# Start cliphist watchers
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

echo "cliphist watchers started..."
