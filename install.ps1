##########################################
# powershell
##########################################
install-module psfzf -force
new-item -type dir ~/.config/powershell -force | out-null
ln -fsv $PSScriptRoot/powershell/profile.ps1 ~/.config/powershell/profile.ps1
new-item -type file ~/.local/dotfiles/powershell/profile.ps1 -force | out-null
##########################################
# vim
##########################################
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -fsv $PSScriptRoot/vim/.vimrc ~/.vimrc
##########################################
# tmux
##########################################
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -fsv $PSScriptRoot/tmux/.tmux.conf ~/.tmux.conf
new-item -type file ~/.local/dotfiles/tmux/tmux.conf -force | out-null
##########################################
# vscode
##########################################
new-item -type dir ~/.config/Code/User -force | out-null
# ln -fsv $PSScriptRoot/vscode/settings.json ~/.config/Code/User/settings.json
# ln -fsv $PSScriptRoot/vscode/keybindings.json ~/.config/Code/User/keybindings.json
copy-item $PSScriptRoot/vscode/settings.json ~/.config/Code/User/settings.json
copy-item $PSScriptRoot/vscode/keybindings.json ~/.config/Code/User/keybindings.json
##########################################
# bash
##########################################
# ln -fsv $PSScriptRoot/bash/bashrc ~/.bashrc
# ln -fsv $PSScriptRoot/bash/bash_profile ~/.bash_profile
