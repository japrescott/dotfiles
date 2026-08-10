#!/bin/bash -i


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
rm -rf ~/.gitconfig ~/.tmux.conf ~/.tmux_theme ~/.tmux ~/.inputrc ~/.config/ghostty ~/.config/starship.toml ~/.config/mise

# Initialize symlinks.
echo ----------------------------
echo Creating symlinks in your home directory that point to this dotfiles repository.
ln -s "$PWD/.inputrc" ~/.inputrc
ln -s "$PWD/.gitconfig" ~/.gitconfig
ln -s "$PWD/.tmux.conf" ~/.tmux.conf
ln -s "$PWD/.tmux_theme" ~/.tmux_theme
ln -s "$PWD/modules/tmux" ~/.tmux
# Ghostty terminal config — also read by cmux (first hit in its config search order).
mkdir -p ~/.config
ln -s "$PWD/.config/ghostty" ~/.config/ghostty
ln -s "$PWD/.config/starship.toml" ~/.config/starship.toml
ln -s "$PWD/.config/mise" ~/.config/mise


# add configs
echo ----------------------------
echo Adding configs
# IntelliJ
#mkdir -p ~/.IntelliJIdea15/config/keymaps/
#ln -s "$PWD/conf/intellij.keymap.xml" ~/.IntelliJIdea15/config/keymaps/MyOwn.keymap.xml



# runtimes (node, python) via mise — versions pinned in .config/mise/config.toml
echo ----------------------------
echo Installing runtimes via mise.
if [ "$dist" == "Ubuntu" ]; then
	curl -fsSL https://mise.run | sh
else
	brew install mise
fi
mise install

# Install global npm packages.
echo ----------------------------
echo Installing global npm packages.
mise exec -- npm install -g \
	typescript \
	ts-node \
	tsx \
	json-log-viewer


# install python via uv
echo ----------------------------
echo Installing python via uv
curl -LsSf https://astral.sh/uv/install.sh | sh
uv python install 3.12
uv python pin 3.12
uv python install --default 3.12
uv generate-shell-completion zsh

# Install python tools
uv tool install black
uv tool install jupyter
uv tool install ruff




# install some dependencies
echo ----------------------------
echo Installing other depedendencies


if [ "$dist" == "Ubuntu" ]; then
	echo "install ubuntu stuff"
	apt-get install -a gitk gitx tmux diff-so-fancy
else
	echo "installing macosx stuff"
	brew install tmux
	brew install git-delta # syntax-highlighted git pager (replaces diff-so-fancy)

	# zsh niceties: inline history suggestions + command syntax highlighting
	brew install zsh-autosuggestions zsh-syntax-highlighting

	brew install viu # for viewing images in terminal
	brew install lsix # for viewing images in ls

	# prompt (replaces the old promptline .shell_prompt.sh)
	brew install starship

	# yazi - Blazing fast terminal file manager written in Rust, based on async I/O.
	brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
	# yazi - fallback for image decoding
	brew install chafa

	# EZA -> ls replacemnet
	brew install eza

	# youtube-dl replacement
	brew install yt-dlp 

fi


# other fun things
echo ----------------------------
echo installing pay-respects # command corrector, replaces the abandoned thefuck
curl -sSfL https://raw.githubusercontent.com/iffse/pay-respects/main/install.sh | sh -s -- --sudo ""

# Finished.
echo ----------------------------
echo Dotfiles installation complete.
