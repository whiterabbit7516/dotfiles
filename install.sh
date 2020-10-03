##########################################
# powershell
##########################################
mkdir -p ~/.config/powershell
ln -fsv $PWD/powershell/profile.ps1 ~/.config/powershell/profile.ps1

##########################################
# vim
##########################################
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -fsv $PWD/vim/.vimrc ~/.vimrc

##########################################
# tmux
##########################################
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -fsv $PWD/tmux/.tmux.conf ~/.tmux.conf

##########################################
# vscode
##########################################
mkdir -p ~/.config/Code/User
# ln -fsv $PWD/vscode/settings.json ~/.config/Code/User/settings.json
# ln -fsv $PWD/vscode/keybindings.json ~/.config/Code/User/keybindings.json
cp $PWD/vscode/settings.json ~/.config/Code/User/settings.json
cp $PWD/vscode/keybindings.json ~/.config/Code/User/keybindings.json
