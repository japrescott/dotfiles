#!/bin/bash

# Initialize and update all submodules.
echo ----------------------------
echo Initializing git submodules.
git submodule init
git submodule update

# install some dependencies
echo ----------------------------
echo Installing some depedendencies
apt-get -v &> /dev/null && apt-get install -a gitk gitx

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
mkdir ~/.IntelliJIdea15/config/keymaps/
ln -s "$PWD/conf/intellij.keymap.xml" ~/.IntelliJIdea15/config/keymaps/MyOwn.keymap.xml


# Finished.
echo ----------------------------
echo Dotfiles installation complete.
