#!/bin/bash

for config in ./.config/*; do
  if [ ! -d "$config" ]; then
    echo "$config is not a directory, skipping..."
    continue
  fi

  config_name=$(basename "$config")
  echo "Setting up $config_name configuration..."

  # Create the target directory if it doesn't exist
  mkdir -p ~/.config/$config_name

  for config_file in $config/*; do
    if [! -f "$config_file" ]; then
      echo "$config_file is not a file, skipping..."
      continue
    fi

    config_file_name = $(basename $config_file)

    # Create hard links for files in the config directory
    ln $config_file ~/.config/$config_name/$config_file_name
  done

  echo "$config_name configuration set up successfully."
done
