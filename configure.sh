#!/bin/bash

name=$1
email=$2
download_directory=~/Downloads
config_directory=~/.config

if [ -z "$name" ] && [ -z "$email" ]
then
	echo "ERROR: Name and email are required positional parameters"
	exit 1
fi


download(){
	link_to_download=$1
	output_file_name=$2
	wget -O ${download_directory}/${output_file_name} "$link_to_download"
}

install_and_configure_git_and_github(){
	sudo apt install git -y
	
	git config --global user.name $name
	git config --global user.email $email
	git config --global init.defaultBranch main
	
	type -p curl >/dev/null || sudo apt install curl -y
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
	
	clear
	echo "-------- AUTH LOGIN FOR GITHUB CLI --------"
	echo "NOTE: you can omit this step just pressing Ctrl+c\n\n"

	gh auth login
}

install_and_configure_nvim(){
	nvim_deb_name=nvim.deb
	nvim_deb_full_path=${download_directory}/${nvim_deb_name}
	download "https://github.com/neovim/neovim/releases/download/v0.8.3/nvim-linux64.deb" $nvim_deb_name

	sudo apt install $nvim_deb_full_path -y
	rm -f $nvim_deb_full_path
	
	if [ -d "${config_directory}/nvim" ]
	then
		backup_file_name="nvim_backup_by_dotfiles"
		rm -fr ${config_directory}/${backup_file_name}
		mv ${config_directory}/nvim ${config_directory}/${backup_file_name}
	fi
	git clone git@github.com:MrRoiz/rnvim.git ${config_directory}/nvim

	# This compiler is required for treesitter
	sudo apt install g++
}

sudo apt update
sudo apt upgrade -y

install_and_configure_git_and_github
install_and_configure_nvim

