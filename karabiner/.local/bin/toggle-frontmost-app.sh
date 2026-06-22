#!/bin/bash
CONFIG_FILE="$HOME/.config/toggle-frontmost-app/env"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
[ -z "${TOGGLE_APP_NAME:-}" ] && exit 0

APP_NAME="$TOGGLE_APP_NAME"
PREV_FILE="/tmp/toggle_frontmost_app_prev.txt"

check_running=$(osascript -e "
tell application \"System Events\"
    set tRunning to exists (process \"$APP_NAME\")
    if tRunning then
        set isFront to frontmost of process \"$APP_NAME\"
        if isFront then
            return \"frontmost\"
        else
            return \"running\"
        end if
    else
        return \"not_running\"
    end if
end tell
")

case "$check_running" in
    frontmost)
        if [ -f "$PREV_FILE" ]; then
            prev_app=$(cat "$PREV_FILE")
            rm "$PREV_FILE"

            osascript -e "tell application \"$prev_app\" to activate" &
            osascript -e "tell application \"System Events\" to set visible of process \"$APP_NAME\" to false" &
            wait
        else
            osascript -e "tell application \"System Events\" to set visible of process \"$APP_NAME\" to false"
        fi
        ;;

    running|not_running)
        if [ "$check_running" = "running" ]; then
            current=$(osascript -e "
                tell application \"System Events\"
                    set cApp to name of first process whose frontmost is true
                end tell
                return cApp
            ")
            if [ -n "$current" ] && [ "$current" != "$APP_NAME" ]; then
                printf "%s\n" "$current" > "$PREV_FILE"
            fi
        fi
        open -a "$APP_NAME"
        ;;
esac
