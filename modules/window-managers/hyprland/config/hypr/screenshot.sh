#!/usr/bin/env bash

# Create screenshots directory if it doesn't exist
#SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
SCREENSHOT_DIR="/tmp/screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with timestamp
FILENAME="$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

# Capture screenshot of selected area, save to file and copy to clipboard
grim -g "$(slurp)" "$FILENAME" && \
wl-copy < "$FILENAME" && \
#swappy -f "$FILENAME"
ksnip "$FILENAME"
