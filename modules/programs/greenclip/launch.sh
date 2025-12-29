#!/usr/bin/env bash

killall -q greenclip

# /usr/local/bin/greenclip daemon &
greenclip daemon &

echo "greenclip launched..."
