#!/usr/bin/env bash
# Emit a line only when a Bluetooth audio device transitions to connected.
set -u
state_dir="${XDG_RUNTIME_DIR:-/tmp}/earbud-island-${UID}"
mkdir -p "$state_dir"
current="$state_dir/connected"
next="$state_dir/connected.new"
if [[ "${1:-}" == "--reset" ]]; then
    rm -f "$current"
fi
: > "$next"

bluetoothctl devices | while read -r _ mac name; do
    [[ -n "${mac:-}" ]] || continue
    info=$(bluetoothctl info "$mac" 2>/dev/null) || continue
    grep -q 'Connected: yes' <<< "$info" || continue
    # Only treat devices with a Bluetooth audio service as earbuds/headphones.
    grep -Eqi 'Audio Sink|Headset|Handsfree|110[8b]|111[e2]' <<< "$info" || continue
    printf '%s\n' "$mac" >> "$next"
    if ! grep -Fxq "$mac" "$current" 2>/dev/null; then
        percent=$(sed -nE \
            's/.*Battery Percentage:.*\(([0-9]+)\).*/\1/p; s/.*Percentage:[[:space:]]*([0-9]+)%?.*/\1/p' \
            <<< "$info" | head -n1)
        printf '%s\t%s\t%s\n' "${name:-Bluetooth audio}" "${percent:-}" "$mac"
    fi
done
mv "$next" "$current"
