##########################################
# powershell
##########################################
ln -fsv $PSScriptRoot/powershell/profile.ps1 ~/.config/powershell/profile.ps1

##########################################
# vim
##########################################
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -fsv $PSScriptRoot/vim/.vimrc ~/.vimrc

##########################################
# tmux
##########################################
ln -fsv $PSScriptRoot/tmux/.tmux.conf ~/.tmux.conf

##########################################
# vscode
##########################################
# ln -fsv $PSScriptRoot/vscode/settings.json ~/.config/Code/User/settings.json
# ln -fsv $PSScriptRoot/vscode/keybindings.json ~/.config/Code/User/keybindings.json
copy-item $PSScriptRoot/vscode/settings.json ~/.config/Code/User/settings.json
copy-item $PSScriptRoot/vscode/keybindings.json ~/.config/Code/User/keybindings.json
