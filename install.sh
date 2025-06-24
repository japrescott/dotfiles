#!/bin/bash


echo ----------------------------
echo Initializing git.

dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`
if [ "$dist" == "Ubuntu" ]; then
	apt-get install -a gitk gitx diff-so-fancy
else
	brew install git
fi



# Initialize and update all submodules.
echo ----------------------------
echo Initializing git submodules.
git submodule init
git submodule update


# Remove all dotfiles from the home directory if present.
echo ----------------------------
echo Removing any existing dotfiles from your home directory.
rm -rf ~/.gitconfig ~/.tmux.conf ~/.tmux_theme ~/.tmux ~/.inputrc

# Initialize symlinks.
echo ----------------------------
echo Creating symlinks in your home directory that point to this dotfiles repository.
ln -s "$PWD/.inputrc" ~/.inputrc
ln -s "$PWD/.gitconfig" ~/.gitconfig
ln -s "$PWD/.tmux.conf" ~/.tmux.conf
ln -s "$PWD/.tmux_theme" ~/.tmux_theme
ln -s "$PWD/modules/tmux" ~/.tmux


# add configs
echo ----------------------------
echo Adding configs
# IntelliJ
mkdir -p ~/.IntelliJIdea15/config/keymaps/
ln -s "$PWD/conf/intellij.keymap.xml" ~/.IntelliJIdea15/config/keymaps/MyOwn.keymap.xml



# installing node via nvm
echo ----------------------------
echo Installing Node.js via nvm.
if [ ! -d "$HOME/.nvm" ]; then
	echo "Installing nvm"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
fi
nvm install --lts
nvm use --lts

# Install global npm packages.
echo ----------------------------
echo Installing global npm packages.
npm install -g \
	typescript \
	ts-node \
	tsx \
	json-log-viewer



# install some dependencies
echo ----------------------------
echo Installing other depedendencies


if [ "$dist" == "Ubuntu" ]; then
	echo "install ubuntu stuff"
	apt-get install -a gitk gitx tmux diff-so-fancy
else
	echo "installing macosx stuff"
	brew install tmux
	brew install diff-so-fancy

	brew install viu # for viewing images in terminal
	brew install lsix # for viewing images in ls

	# yazi - Blazing fast terminal file manager written in Rust, based on async I/O.
	brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
	# yazi - fallback for image decoding
	brew install chafa

fi


# other fun things
echo ----------------------------
echo installing thefuck
pip install thefuck

# Finished.
echo ----------------------------
echo Dotfiles installation complete.
