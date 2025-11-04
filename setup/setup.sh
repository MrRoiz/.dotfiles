#! /usr/bin/env bash

###################
#       WIP       #
###################

# Install yay
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install packages
yay -S --needed
