#!/usr/bin/env bash

# Check if YouTube/Google Meet/Microsoft Teams is playing
check_media_playing() {
    printf "[DEBUG] check_media_playing: START\n" >&2
    if command -v pactl &> /dev/null; then
        printf "[DEBUG] pactl found, checking sink inputs...\n" >&2
	# Check if any browser has an active (not corked) audio stream
        # Parse sink inputs and look for browser apps with Corked: no (playing) state
        # Also check for meeting apps (Google Meet, Microsoft Teams)
        pactl list sink-inputs 2>/dev/null | awk '
            BEGIN { 
                interested=0; 
                playing_found=0;
                print "[DEBUG] AWK: Starting sink-input parsing" > "/dev/stderr"
            }
            /application.name = "(Google Chrome|Chromium|Firefox)/ { 
                interested=1;
                print "[DEBUG] AWK: Browser found: " $0 > "/dev/stderr"
            }
            /application.name = "Microsoft Teams"/ { 
                interested=1;
                print "[DEBUG] AWK: Microsoft Teams found: " $0 > "/dev/stderr"
            }
            /media.name/ && /(Meet|Teams|meet\.google|teams\.microsoft)/ { 
                interested=1;
                print "[DEBUG] AWK: Meeting media detected: " $0 > "/dev/stderr"
            }
            /Corked: no/ { 
                if (interested) {
                    playing_found=1;
                    print "[DEBUG] AWK: Application has Corked: no (playing)" > "/dev/stderr"
                }
            }
            /pulse.corked = "false"/ { 
                if (interested && !playing_found) {
                    playing_found=1;
                    print "[DEBUG] AWK: Application has pulse.corked = false (playing)" > "/dev/stderr"
                }
            }
            /Sink Input #/ { 
                printf "[DEBUG] AWK: Processing new sink input - interested=%d playing_found=%d\n", interested, playing_found > "/dev/stderr"
		if (interested && playing_found) {
                    print "[DEBUG] AWK: Match found! Exiting with success" > "/dev/stderr"
                    exit 0
                }
                interested=0
                playing_found=0
            }
            END { 
                printf "[DEBUG] AWK: END - interested=%d playing_found=%d\n", interested, playing_found > "/dev/stderr"
                exit (interested && playing_found) ? 0 : 1 
            }
        '
        local exit_code=$?
        printf "[DEBUG] pactl check completed with exit code: %d\n" $exit_code >&2
        
        # If audio check found something, return success
        if [ $exit_code -eq 0 ]; then
            return 0
        fi
        
        # Also check for meeting windows using xdotool as fallback
        if command -v xdotool &> /dev/null; then
            printf "[DEBUG] Checking for meeting windows with xdotool...\n" >&2
            if xdotool search --name --class ".*(Meet|Teams|Google Meet|Microsoft Teams).*" 2>/dev/null | head -1 | grep -q .; then
                printf "[DEBUG] Meeting window found via xdotool\n" >&2
                return 0
            fi
        fi
        
        return $exit_code
    else
        printf "[DEBUG] pactl not found, trying fallback method...\n" >&2
        # Fallback: check if YouTube/Meet/Teams window exists
        if command -v xdotool &> /dev/null; then
            printf "[DEBUG] xdotool found, searching for media windows...\n" >&2
            if xdotool search --name "YouTube" 2>/dev/null | head -1 | grep -q . || \
               xdotool search --name --class ".*(Meet|Teams|Google Meet|Microsoft Teams).*" 2>/dev/null | head -1 | grep -q .; then
                printf "[DEBUG] Media window found via xdotool\n" >&2
                return 0
            fi
            return 1
        else
            printf "[DEBUG] xdotool not found, no fallback available\n" >&2
            return 1
        fi
    fi
}

# Main logic
printf "[DEBUG] Main: Starting media check...\n" >&2
if check_media_playing; then
    # YouTube/browser audio or meeting is active, don't lock
    printf "[DEBUG] Main: Media/meeting detected, not locking\n" >&2
    exit 0
else
    # No media playing, proceed with lock
    printf "[DEBUG] Main: No media/meeting detected, proceeding with lock\n" >&2
    i3lock -d -c 000000
fi
