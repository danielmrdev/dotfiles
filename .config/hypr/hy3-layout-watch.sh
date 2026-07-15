#!/bin/bash
# hy3-layout-watch: auto-tab workspace 4 (Teams+Outlook) when on laptop only.
# Listens to Hyprland events and monitor changes.

LAPTOP_MONITOR="eDP-1"
TARGET_WS="4"

is_laptop_only() {
    local count
    count=$(hyprctl monitors -j | jq 'length')
    # Exactly 1 monitor = laptop screen only
    [ "$count" -eq 1 ] && return 0
    # Or: only laptop monitor is connected (handles external monitors disabled)
    local laptop_only
    laptop_only=$(hyprctl monitors -j | jq "[.[] | select(.name==\"$LAPTOP_MONITOR\")] | length")
    [ "$laptop_only" -eq 1 ] && [ "$count" -eq 1 ] && return 0
    return 1
}

apply_tab_layout() {
    # Check if ws4 has windows
    local ws4_windows
    ws4_windows=$(hyprctl clients -j | jq "[.[] | select(.workspace.id==$TARGET_WS)] | length")
    [ "$ws4_windows" -lt 2 ] && return

    # Save current workspace
    local current_ws
    current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

    # Switch to ws4, apply tab, switch back
    hyprctl dispatch workspace "$TARGET_WS"
    hyprctl dispatch hy3:changegroup tab

    [ "$current_ws" != "$TARGET_WS" ] && hyprctl dispatch workspace "$current_ws"
}

# Initial check at startup
is_laptop_only && apply_tab_layout

# Watch for window events
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
if [ -S "$SOCKET" ]; then
    socat -U - "UNIX-CONNECT:$SOCKET" | while read -r event; do
        case "$event" in
            window>>\"$TARGET_WS\"*|window>>[0-9]*|openwindow\>\>*)
                is_laptop_only && apply_tab_layout
                ;;
            monitoradded\>\>*|monitorremoved\>\>*)
                sleep 0.5
                if is_laptop_only; then
                    apply_tab_layout
                fi
                ;;
        esac
    done
fi
