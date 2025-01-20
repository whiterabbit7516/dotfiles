##########################################
# variables
##########################################
SCRIPTPATH=${BASH_SOURCE[0]}
SCRIPTROOT="$(dirname $SCRIPTPATH)"
##########################################
# powershell
##########################################
mkdir -p ~/.config/powershell
ln -fsv $SCRIPTROOT/powershell/profile.ps1 ~/.config/powershell/profile.ps1
mkdir -p ~/.local/dotfiles/powershell
touch ~/.local/dotfiles/powershell/profile.ps1
##########################################
# vim
##########################################
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -fsv $SCRIPTROOT/vim/.vimrc ~/.vimrc
##########################################
# tmux
##########################################
ln -fsv $SCRIPTROOT/tmux/.tmux.conf ~/.tmux.conf
mkdir -p ~/.local/dotfiles/tmux
touch ~/.local/dotfiles/tmux/tmux.conf
##########################################
# vscode
##########################################
mkdir -p ~/.config/Code/User
# ln -fsv $SCRIPTROOT/vscode/settings.json ~/.config/Code/User/settings.json
# ln -fsv $SCRIPTROOT/vscode/keybindings.json ~/.config/Code/User/keybindings.json
cp $SCRIPTROOT/vscode/settings.json ~/.config/Code/User/settings.json
cp $SCRIPTROOT/vscode/keybindings.json ~/.config/Code/User/keybindings.json
##########################################
# bash
##########################################
# ln -fsv $SCRIPTROOT/bash/bashrc ~/.bashrc
# ln -fsv $SCRIPTROOTWD/bash/bash_profile ~/.bash_profile
