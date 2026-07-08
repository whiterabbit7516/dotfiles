#!/bin/bash
##########################################
# variables
##########################################
SCRIPTPATH=$(realpath "${BASH_SOURCE[0]}")
SCRIPTROOT="$(dirname $SCRIPTPATH)"
##########################################
# powershell
##########################################
mkdir -p ~/.config/powershell
ln -fsv $SCRIPTROOT/powershell/profile.ps1 ~/.config/powershell/profile.ps1
##########################################
# vim
##########################################
ln -fsv $SCRIPTROOT/vim/.vimrc ~/.vimrc
##########################################
# tmux
##########################################
ln -fsv $SCRIPTROOT/tmux/.tmux.conf ~/.tmux.conf
##########################################
# vscode
##########################################
mkdir -p ~/.config/Code/User
cp -n $SCRIPTROOT/vscode/settings.json ~/.config/Code/User/settings.json
cp -n $SCRIPTROOT/vscode/keybindings.json ~/.config/Code/User/keybindings.json
##########################################
# bash
##########################################
# ln -fsv $SCRIPTROOT/bash/bashrc ~/.bashrc
# ln -fsv $SCRIPTROOTWD/bash/bash_profile ~/.bash_profile
##########################################
# claude
##########################################
mkdir -p ~/.claude
cp -n $SCRIPTROOT/claude/settings.json ~/.claude/settings.json
cp -n $SCRIPTROOT/claude/claude.json ~/.claude.json
