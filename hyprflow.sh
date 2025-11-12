#!/bin/bash

# --- Path Initialization ---
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# --- 2. Configuration Clusters ---

# A. Tab-Closing Browsers (Action: Node.js Tab Close)
BROWSER_CLASSES="firefox"
BROWSER_BLOCKED_KEYWORDS="YouTube|Discord"
# >>> TO OVERRIDE, REPLACE THE LINE BELOW WITH YOUR CUSTOM ABSOLUTE PATH: <<<
BROWSER_ACTION_PATH="$SCRIPT_DIR/close-tab.js" 

# B. Window-Kill Applications (Action: hyprctl dispatch killwindow)
WINDOW_KILL_CLASSES="gimp"
WINDOW_KILL_BLOCKED_KEYWORDS="GNU Image Manipulation Program" 

# C. Process-Kill Applications (Action: pkill -f)
PROCESS_KILL_CLASSES="steam"
PROCESS_KILL_BLOCKED_KEYWORDS="Steam" 

# D. Shared Settings
POLLING_INTERVAL=0.5

# --- Internal Variables ---
ALL_BLOCKED_KEYWORDS="$BROWSER_BLOCKED_KEYWORDS|$WINDOW_KILL_BLOCKED_KEYWORDS|$PROCESS_KILL_BLOCKED_KEYWORDS"
WATCHED_CLASSES="$BROWSER_CLASSES,$WINDOW_KILL_CLASSES,$PROCESS_KILL_CLASSES" 

# --- Helper Function: Timestamp ---
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# --- Helper Function: Notification ---
# Sends a status notification via the D-Bus service (compatible with Dunst, Mako, etc.)
notify_status() {
    # Check if notify-send is available before trying to use it
    if command -v notify-send >/dev/null 2>&1; then
        local summary="$1"
        local body="$2"
        # -a Hyprflow (App Name), -t 5000 (5 second timeout)
        notify-send -a Hyprflow -t 5000 "$summary" "$body"
    fi
}

# --- Shutdown Trap ---
# Sends the 'Stopped' notification whenever the script exits due to signals (kill, Ctrl+C)
trap 'notify_status "Hyprflow Status" "Hyprflow has stopped monitoring windows."; exit 0' SIGHUP SIGINT SIGTERM EXIT

# --- Startup Messages & Notification ---
echo "[$(timestamp)] Hyprflow started."
notify_status "Hyprflow Status" "Hyprflow is now running and monitoring windows."
echo "[$(timestamp)] Browsers (Tab Cancel) Keywords: $BROWSER_BLOCKED_KEYWORDS"
echo "[$(timestamp)] Window Kill Keywords: $WINDOW_KILL_BLOCKED_KEYWORDS"
echo "[$(timestamp)] Process Kill Keywords: $PROCESS_KILL_BLOCKED_KEYWORDS"


# --- Main Polling Loop ---
while true; do

    ALL_CLIENTS=$(hyprctl clients -j)

    # 1. INITIAL FILTER: Find windows that match ANY watched class and ANY blocked keyword.
    MATCHING_WINDOWS=$(echo "$ALL_CLIENTS" | jq -c \
        ".[] | 
        select(
            (.class | inside(\"$WATCHED_CLASSES\")) and 
            (.title | test(\"($ALL_BLOCKED_KEYWORDS)\"; \"i\")) 
        )")

    if [ -n "$MATCHING_WINDOWS" ]; then
        
        # 2. Iterate over the potential matches for precise checking
        echo "$MATCHING_WINDOWS" | while read -r WINDOW_JSON; do
            
            ADDRESS=$(echo "$WINDOW_JSON" | jq -r '.address')
            CLASS=$(echo "$WINDOW_JSON" | jq -r '.class')
            TITLE=$(echo "$WINDOW_JSON" | jq -r '.title')
            
            # --- ACTION LOGIC START: Check Class AND its SPECIFIC Keyword List ---
            
            # Action A: Browser Check (Tab Cancel)
            if [[ ",$BROWSER_CLASSES," == *,"$CLASS,"* ]]; then
                if [[ "$TITLE" =~ $BROWSER_BLOCKED_KEYWORDS ]]; then
                    echo "[$(timestamp)] HYPRFLOW BLOCK ($TITLE): Triggering Node.js tab check..."
                    "$BROWSER_ACTION_PATH" "$BROWSER_BLOCKED_KEYWORDS"
                fi
                
            # Action B: Window Kill Check (hyprctl dispatch killwindow)
            elif [[ ",$WINDOW_KILL_CLASSES," == *,"$CLASS,"* ]]; then
                if [[ "$TITLE" =~ $WINDOW_KILL_BLOCKED_KEYWORDS ]]; then
                    echo "[$(timestamp)] HYPRFLOW BLOCK ($TITLE): Closing specific window $ADDRESS..."
                    hyprctl dispatch killwindow address:"$ADDRESS"
                fi
            
            # Action C: Process Kill Check (pkill -f)
            elif [[ ",$PROCESS_KILL_CLASSES," == *,"$CLASS,"* ]]; then
                if [[ "$TITLE" =~ $PROCESS_KILL_BLOCKED_KEYWORDS ]]; then
                    echo "[$(timestamp)] HYPRFLOW BLOCK ($TITLE): Killing ALL processes for class '$CLASS'..."
                    pkill -f "$CLASS"
                fi
            fi
            
            # --- ACTION LOGIC END ---
            
        done
        
    fi

    sleep "$POLLING_INTERVAL"

done
