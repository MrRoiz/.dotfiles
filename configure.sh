#!/bin/bash

name=$1
email=$2
download_directory=~/Downloads
config_directory=~/.config
dotfiles_config_directory=./config_files
real_kitty_config_directory=${config_directory}/kitty
dotfiles_kitty_config=${dotfiles_config_directory}/kitty.conf
fonts_directory=~/.fonts
zshrc_file=~/.zshrc


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

	# Dependencies required for treesitter live_grep
	sudo apt install g++ ripgrep -y
}

install_node_and_yarn(){
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
	nvm install --lts
	npm i -g yarn -y
}

install_zsh_and_ohmyszh(){
	sudo apt install zsh -y
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	chsh -s $(which zsh)

	sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' $zshrc_file

	# Custom Plugins
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
	git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
	sed -i 's/plugins=(git)/plugins=(\n\tgit\n\tzsh-syntax-highlighting\n\tzsh-autosuggestions\n\tzsh-history-substring-search\n\tyou-should-use\n\tweb-search\n/g)' $zshrc_file

	echo "bindkey '^[[A' history-substring-search-up\nbindkey '^[[B' history-substring-search-down" >> $zshrc_file

	clear
	echo "When this process finishes you can reopen the terminal and the theme cutomization will start"
	echo "This message will be skipped in 5 seconds"
	sleep 5
    clear
}

install_and_configure_kitty_terminal(){
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

	# Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in
	# your system-wide PATH)
	ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
	# Place the kitty.desktop file somewhere it can be found by the OS
	cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
	# If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
	cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
	# Update the paths to the kitty and its icon in the kitty.desktop file(s)
	sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
	sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

	mkdir -p $real_kitty_config_directory
	ln $dotfiles_kitty_config $real_kitty_config_directory

	# Set kitty as default terminal
	sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $(which kitty) 50
}

install_jetbrains_font(){
	font_zip_file=font.zip
	font_directory=${download_directory}/font
	font_zip_file_full_path=${download_directory}/${font_zip_file}

	download "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip" $font_zip_file
	unzip ${font_zip_file_full_path} -d ${font_directory}

	mkdir -p $fonts_directory

	cp ${font_directory}/*.ttf $fonts_directory

	rm -fr $font_zip_file font_directory
}

install_docker(){
	sudo apt-get remove docker docker-engine docker.io containerd runc -y

	sudo apt-get update
	sudo apt-get install \
		ca-certificates \
		curl \
		gnupg \
		lsb-release

	sudo mkdir -m 0755 -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt update
	sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

add_some_custom_aliases(){
	echo "\n\nalias v=nvim" >> $zshrc_file
}

install_and_configure_tmux(){
	sudo apt install tmux -y
	temp_zshrc=~/.deleteme

	# Open tmux when zsh opens
	sudo echo 'if [ "$TMUX" = "" ]; then tmux; fi' | cat - $zshrc_file > $temp_zshrc && mv $temp_zshrc $zshrc_file
}

sudo apt update
sudo apt upgrade -y

install_jetbrains_font
install_and_configure_git_and_github
install_docker
install_zsh_and_ohmyszh
install_node_and_yarn
add_some_custom_aliases
install_and_configure_nvim
install_and_configure_kitty_terminal
install_and_configure_tmux
