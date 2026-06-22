#!/usr/bin/env bash
set -euo pipefail

HTTP="http://localhost:55777"
KBD="${HOME}/.local/bin/kbd-brightness"
STATE_DIR="${HOME}/.local/state"
STATE_FILE="${STATE_DIR}/betterdisplay-brightness-toggle.state"
DEFAULT_RESTORE="${DEFAULT_RESTORE:-0.7}"

mkdir -p "$STATE_DIR"

# --- Read state ---
TOGGLE_STATE=""
CACHE_TIME=0
BD_AVAILABLE=""
KBD_SAVED="0.5"
DISPLAY_IDS=()
MIN_VALS=()
SAVED=()

if [ -f "$STATE_FILE" ]; then
    exec 4<"$STATE_FILE"
    while IFS= read -r line <&4; do
        case "$line" in
            *\|*)
                IFS='|' read -r id min saved <<< "$line"
                [ -n "$id" ] || continue
                DISPLAY_IDS+=("$id")
                MIN_VALS+=("$min")
                SAVED+=("$saved")
                ;;
            TOGGLE_STATE=*) TOGGLE_STATE="${line#TOGGLE_STATE=}" ;;
            CACHE_TIME=*)   CACHE_TIME="${line#CACHE_TIME=}" ;;
            BD_AVAILABLE=*) BD_AVAILABLE="${line#BD_AVAILABLE=}" ;;
            KBD_SAVED=*)    KBD_SAVED="${line#KBD_SAVED=}" ;;
        esac
    done
    exec 4<&-
fi

# --- Check BetterDisplay availability (cached) ---
if [ "$BD_AVAILABLE" != "yes" ]; then
    if [ "$BD_AVAILABLE" = "no" ]; then
        echo "[toggle-brightness] BetterDisplay not available (delete state file to re-check)" >&2
        exit 1
    fi

    BD_MSG=""
    if [ ! -d "/Applications/BetterDisplay.app" ]; then
        BD_MSG="BetterDisplay.app not found at /Applications"
        BD_AVAILABLE="no"
    elif ! curl -sf "$HTTP/get?type=Display&identifier=tagID" > /dev/null 2>&1; then
        BD_MSG="BetterDisplay HTTP API unavailable on $HTTP"
        BD_AVAILABLE="no"
    else
        BD_AVAILABLE="yes"
    fi

    if [ "$BD_AVAILABLE" = "no" ]; then
        echo "BD_AVAILABLE=no" > "$STATE_FILE"
        echo "[toggle-brightness] $BD_MSG" >&2
        exit 1
    fi
fi

# --- Toggle logic ---

if [ "$TOGGLE_STATE" = "dimmed" ]; then
    # --- RESTORE ---
    restored=0
    for i in "${!DISPLAY_IDS[@]}"; do
        curl -sf "$HTTP/set?tagID=${DISPLAY_IDS[$i]}&brightness=${SAVED[$i]}" > /dev/null &
        restored=1
    done
    "$KBD" "$KBD_SAVED" > /dev/null 2>/dev/null &
    wait

    if [ "$restored" -eq 0 ]; then
        ids=$(curl -sf "$HTTP/get?type=Display&identifier=tagID" 2>/dev/null | tr ',' '\n') || exit 0
        for id in $ids; do
            [ -n "$id" ] || continue
            curl -sf "$HTTP/set?tagID=$id&brightness=$DEFAULT_RESTORE" > /dev/null &
        done
        wait
    fi

    {
        echo "TOGGLE_STATE=restored"
        echo "CACHE_TIME=$CACHE_TIME"
        echo "BD_AVAILABLE=$BD_AVAILABLE"
        echo "KBD_SAVED=$KBD_SAVED"
        for i in "${!DISPLAY_IDS[@]}"; do
            echo "${DISPLAY_IDS[$i]}|${MIN_VALS[$i]}|${SAVED[$i]}"
        done
    } > "$STATE_FILE"
    exit 0
fi

# --- DIM path ---

# Save keyboard brightness before dimming
KBD_SAVED=$("$KBD" 2>/dev/null || echo "0.5")

# Get current display list from BetterDisplay (handles hotplug)
current_ids=$(curl -sf "$HTTP/get?type=Display&identifier=tagID" 2>/dev/null | tr ',' '\n') || exit 0

# Build fresh arrays: query each display ONCE for min + current brightness
NEW_IDS=()
NEW_MINS=()
NEW_SAVED=()

for id in $current_ids; do
    [ -n "$id" ] || continue
    triplet=$(curl -sf "$HTTP/get?tagID=$id&brightness&min&max&value" 2>/dev/null) || continue
    IFS=, read -r current min _ <<< "$triplet"
    NEW_IDS+=("$id")
    NEW_MINS+=("$min")
    NEW_SAVED+=("$current")
done

DISPLAY_IDS=("${NEW_IDS[@]}")
MIN_VALS=("${NEW_MINS[@]}")
SAVED=("${NEW_SAVED[@]}")
CACHE_TIME=$(date +%s)

# Dim all displays + keyboard in parallel
for i in "${!DISPLAY_IDS[@]}"; do
    curl -sf "$HTTP/set?tagID=${DISPLAY_IDS[$i]}&brightness=${MIN_VALS[$i]}" > /dev/null &
done
"$KBD" 0 > /dev/null 2>/dev/null &
wait

# Save state
{
    echo "TOGGLE_STATE=dimmed"
    echo "CACHE_TIME=$CACHE_TIME"
    echo "BD_AVAILABLE=$BD_AVAILABLE"
    echo "KBD_SAVED=$KBD_SAVED"
    for i in "${!DISPLAY_IDS[@]}"; do
        echo "${DISPLAY_IDS[$i]}|${MIN_VALS[$i]}|${SAVED[$i]:-$DEFAULT_RESTORE}"
    done
} > "$STATE_FILE"
