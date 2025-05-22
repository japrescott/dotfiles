#!/bin/bash

# Initialize and update all submodules.
echo ----------------------------
echo Initializing git submodules.
git submodule init
git submodule update

# install some dependencies
echo ----------------------------
echo Installing some depedendencies

dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`
if [ "$dist" == "Ubuntu" ]; then
	echo "install ubuntu stuff"
	apt-get install -a gitk gitx diff-so-fancy
else
	echo "installing macosx stuff"
	brew install tmux
	brew install diff-so-fancy

	brew install viu # for viewing images in terminal
	brew install lsix # for viewing images in ls
	
fi

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


# other fun things
echo ----------------------------
echo installing thefuck
pip install thefuck

# Finished.
echo ----------------------------
echo Dotfiles installation complete.
