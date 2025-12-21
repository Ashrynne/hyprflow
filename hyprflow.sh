#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BROWSER_ACTION_PATH="$SCRIPT_DIR/close-tab.js" 
POLLING_INTERVAL=0.5

# =====================================================
# Set up stuff below ###
# =====================================================

# Separate keywords with "|". Add however many clusters you want. You can have several clusters for a single browser, depending on how elaborate you want it
# Keywords are case-sensitive and need to be exact if you want accurate detection
# The example keywords are basic, but you can be as specific as you want

# Browser control(closing tabs only)
declare -A BROWSER_CLUSTERS
BROWSER_CLUSTERS["chromium"]="YouTube|Discord"
BROWSER_CLUSTERS["brave-browser"]="Reddit|Twitter|Facebook"
BROWSER_CLUSTERS["google-chrome"]="Netflix|DisneyPlus"

# Window control(Specific window via address)
declare -A WINDOW_KILL_CLUSTERS
WINDOW_KILL_CLUSTERS["gimp"]="GNU Image Manipulation Program"
WINDOW_KILL_CLUSTERS["obsidian"]="Notes|Personal"

# Process control(Kills 'em for good)
declare -A PROCESS_KILL_CLUSTERS
PROCESS_KILL_CLUSTERS["steam"]="Steam"
PROCESS_KILL_CLUSTERS["vlc"]="Movie|Video"

# =======================================================
# End of setup section, boring logic ahead
# =======================================================

timestamp() { date +"%Y-%m-%d %H:%M:%S"; }

notify_status() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a Hyprflow -t 3000 "$1" "$2"
    fi
}

# global filter creation(for jq)
WATCHED_CLASSES_REGEX=$(echo "${!BROWSER_CLUSTERS[@]} ${!WINDOW_KILL_CLUSTERS[@]} ${!PROCESS_KILL_CLUSTERS[@]}" | sed 's/ /|/g')

# If you want, change notification messages for whatever daemon you're using, but be careful with them quotations ;)

trap 'notify_status "Hyprflow" "Time for a breather, right?"; exit 0' SIGHUP SIGINT SIGTERM EXIT

echo "[$(timestamp)] Hyprflow started with indexed clusters."
notify_status "Hyprflow" "Ready to hunt..."

while true; do
    ALL_CLIENTS=$(hyprctl clients -j)

    # Initial fast filter: find any window whose class is in the clusters
    MATCHING_WINDOWS=$(echo "$ALL_CLIENTS" | jq -c ".[] | select(.class | test(\"$WATCHED_CLASSES_REGEX\"))")

    if [ -n "$MATCHING_WINDOWS" ]; then
        echo "$MATCHING_WINDOWS" | while read -r WINDOW_JSON; do
            ADDRESS=$(echo "$WINDOW_JSON" | jq -r '.address')
            CLASS=$(echo "$WINDOW_JSON" | jq -r '.class')
            TITLE=$(echo "$WINDOW_JSON" | jq -r '.title')

            # --- Check Browser Clusters ---
            if [[ -n "${BROWSER_CLUSTERS[$CLASS]}" ]]; then
                KEYWORDS="${BROWSER_CLUSTERS[$CLASS]}"
                if [[ "$TITLE" =~ $KEYWORDS ]]; then
                    echo "[$(timestamp)] Cluster Match (Browser): $CLASS -> $TITLE"
                    node "$BROWSER_ACTION_PATH" "$KEYWORDS" &
                fi

            # --- Check Window Kill Clusters ---
            elif [[ -n "${WINDOW_KILL_CLUSTERS[$CLASS]}" ]]; then
                KEYWORDS="${WINDOW_KILL_CLUSTERS[$CLASS]}"
                if [[ "$TITLE" =~ $KEYWORDS ]]; then
                    echo "[$(timestamp)] Cluster Match (Window): $CLASS -> $TITLE"
                    hyprctl dispatch killwindow address:"$ADDRESS"
                fi

            # --- Check Process Kill Clusters ---
            elif [[ -n "${PROCESS_KILL_CLUSTERS[$CLASS]}" ]]; then
                KEYWORDS="${PROCESS_KILL_CLUSTERS[$CLASS]}"
                if [[ "$TITLE" =~ $KEYWORDS ]]; then
                    echo "[$(timestamp)] Cluster Match (Process): $CLASS -> $TITLE"
                    pkill -f "$CLASS"
                fi
            fi
        done
    fi
    sleep "$POLLING_INTERVAL"
done
