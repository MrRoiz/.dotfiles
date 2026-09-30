#!/usr/bin/env bash
#
# Low-battery warning: sends a notification and plays a sound once per
# threshold, per discharge cycle. Intended to be run by the
# battery-warning.timer systemd user unit (every minute).
#
set -euo pipefail

thresholds=(20 10 5)
sound="$HOME/.dotfiles/scripts/sounds/low-battery.mp3"
state_file="${XDG_RUNTIME_DIR:-/tmp}/battery-warning.state"

# First battery device.
battery=""
for d in /sys/class/power_supply/BAT*; do
  if [ -r "$d/capacity" ]; then
    battery="$d"
    break
  fi
done
[ -n "$battery" ] || exit 0

capacity=$(cat "$battery/capacity")
status=$(cat "$battery/status" 2>/dev/null || true)

# Not discharging (charging / full / plugged) -> clear cycle state.
if [ "$status" != "Discharging" ]; then
  rm -f "$state_file"
  exit 0
fi

# Most severe threshold already warned this cycle; 999 means none yet.
last=999
if [ -r "$state_file" ]; then
  last=$(cat "$state_file")
fi

# Most severe threshold reached at the current capacity.
current=999
for t in "${thresholds[@]}"; do
  if [ "$capacity" -le "$t" ]; then
    current=$t
  fi
done

[ "$current" -lt "$last" ] || exit 0

if [ "$current" -le 10 ]; then
  urgency=critical
  title="Battery critical"
  body="<span foreground='#f07178'>Only ${capacity}% left — plug in now.</span>"
else
  urgency=normal
  title="Battery low"
  body="<span foreground='#ffb454'>${capacity}% remaining. Plug in a charger.</span>"
fi

notify-send -a battery -u "$urgency" -i battery "${title} — ${capacity}%" "$body" || true

if [ -r "$sound" ]; then
  pw-play --volume 1.0 "$sound" >/dev/null 2>&1 || paplay --volume 0x10000 "$sound" >/dev/null 2>&1 || true
fi

echo "$current" > "$state_file"
