upgrade() {
  read -q "?Are you sure you want to sync your system? [y/N] " || {
    echo
    return 1
  }
  echo
  bash "$HOME/.dotfiles/install.sh"
}

update_dns() {
  if [ -z "$1" ]; then
    echo "Argument required: DNS server IP"
    return 1
  fi

  current_network=$(nmcli -t -f name connection show --active | head -1)
  connection_type=$(nmcli -t -f type connection show --active | head -1)

  if [ "$connection_type" != "802-11-wireless" ]; then
    echo "Not connected to WiFi (current: $connection_type)"
    return 1
  fi

  nmcli connection modify "$current_network" ipv4.dns "$1"
  nmcli con mod "$current_network" ipv4.ignore-auto-dns yes
  systemctl restart NetworkManager

  echo "DNS server for ($current_network) updated to ($1)"
}
