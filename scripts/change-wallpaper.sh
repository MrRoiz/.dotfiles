#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "In order to execute the script you need to run it using sudo."
  exit 1
fi

sddm_background_dir=/usr/share/sddm/themes/silent/backgrounds

background_dir="$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)/.dotfiles/wallpapers"
background_path=$(find $background_dir -not -name actual | fzf)

if [ -z "$background_path" ]; then
  echo "No wallpaper selected."
  exit 1
fi

if [ -f "$background_dir/actual" ]; then
  rm "$background_dir/actual"
fi
ln -s $background_path $background_dir/actual

# To update SDDM we need to create an actual copy of the file in the /usr/share/sddm/themes/silent/backgrounds
# under the name of actual
if [ -f "$sddm_background_dir/actual" ]; then
  rm "$sddm_background_dir/actual"
fi
cp $background_path "$sddm_background_dir/actual"
