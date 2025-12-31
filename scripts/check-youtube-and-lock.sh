#!/usr/bin/env bash

# Check if YouTube is playing by checking for active audio from browsers
check_youtube_playing() {
    if command -v pactl &> /dev/null; then
        # Check if any browser has an active (RUNNING) audio stream
        # Parse sink inputs and look for browser apps with RUNNING state
        pactl list sink-inputs 2>/dev/null | awk '
            BEGIN { browser_found=0; running_found=0 }
            /application.name = "(Google Chrome|Chromium|Firefox)/ { browser_found=1 }
            /state = RUNNING/ { if (browser_found) running_found=1 }
            /Sink Input #/ { 
                if (browser_found && running_found) exit 0
                browser_found=0
                running_found=0
            }
            END { exit (browser_found && running_found) ? 0 : 1 }
        '
        return $?
    else
        # Fallback: check if YouTube tab exists (less reliable)
        if command -v xdotool &> /dev/null; then
            xdotool search --name "YouTube" &> /dev/null
            return $?
        fi
        return 1
    fi
}

# Main logic
if check_youtube_playing; then
    # YouTube/browser audio is playing, don't lock
    exit 0
else
    # No YouTube playing, proceed with lock
    i3lock -d -c 000000
fi
