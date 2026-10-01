#!/bin/sh
# Toggle/state helpers for the swaync control-center buttons-grid.
#
#   toggles.sh toggle      <wifi|bt|mic>
#   toggles.sh state       <wifi|bt|mic>          # echoes true/false (update-command)
#   toggles.sh set-profile <performance|balanced|power-saver>
#
# Profiles are plain buttons (not swaync toggles) so that switching profile
# doesn't need a drawer refresh: the active one is highlighted by a tiny
# generated stylesheet that style.css imports, then reloaded with -rs.

set -u

PROFILE_CSS="$HOME/.config/swaync/profile-active.css"

wifi_state() {
  if [ "$(nmcli -t -f WIFI general 2>/dev/null)" = "enabled" ]; then
    echo true
  else
    echo false
  fi
}

bt_state() {
  if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo true
  else
    echo false
  fi
}

mic_state() {
  if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q "\[MUTED\]"; then
    echo false
  else
    echo true
  fi
}

profile_index() {
  case "${1:-}" in
    power-saver) echo 1 ;;
    balanced) echo 2 ;;
    performance) echo 3 ;;
  esac
}

write_profile_css() {
  idx=$(profile_index "$1")
  [ -n "$idx" ] || return 0
  printf '.widget-buttons-grid.profiles flowboxchild:nth-child(%s) > button {\n  background: #2b271f;\n  color: #e6b450;\n}\n' \
    "$idx" > "$PROFILE_CSS"
}

case "${1:-}" in
  state)
    case "${2:-}" in
      wifi) wifi_state ;;
      bt) bt_state ;;
      mic) mic_state ;;
    esac
    ;;
  set-profile)
    case "${2:-}" in
      performance|balanced|power-saver)
        powerprofilesctl set "$2"
        write_profile_css "$2"
        swaync-client -rs >/dev/null 2>&1
        ;;
    esac
    ;;
  toggle)
    case "${2:-}" in
      wifi)
        if [ "$(wifi_state)" = true ]; then
          nmcli radio wifi off
        else
          nmcli radio wifi on
        fi
        ;;
      bt)
        if [ "$(bt_state)" = true ]; then
          bluetoothctl power off
        else
          bluetoothctl power on
        fi
        ;;
      mic)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
    esac
    ;;
esac
