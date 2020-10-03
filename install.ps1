##########################################
# powershell
##########################################
new-item -type dir ~/.config/powershell -force | out-null
ln -fsv $PSScriptRoot/powershell/profile.ps1 ~/.config/powershell/profile.ps1

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

##########################################
# vscode
##########################################
new-item -type dir ~/.config/Code/User -force | out-null
# ln -fsv $PSScriptRoot/vscode/settings.json ~/.config/Code/User/settings.json
# ln -fsv $PSScriptRoot/vscode/keybindings.json ~/.config/Code/User/keybindings.json
copy-item $PSScriptRoot/vscode/settings.json ~/.config/Code/User/settings.json
copy-item $PSScriptRoot/vscode/keybindings.json ~/.config/Code/User/keybindings.json
