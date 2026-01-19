#!/bin/bash

background_dir="$HOME/.dotfiles/wallpapers"
background_path=$(find $background_dir -not -name actual | fzf)

if [ -z "$background_path" ]; then
  echo "No wallpaper selected."
  exit 1
fi

if [ -f "$background_dir/actual" ]; then
  rm "$background_dir/actual"
fi
ln -s $background_path $background_dir/actual
