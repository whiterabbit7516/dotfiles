##########################################
# powershell
##########################################
mkdir -p ~/.config/powershell
ln -fsv $PWD/powershell/profile.ps1 ~/.config/powershell/profile.ps1
mkdir -p ~/.local/dotfiles/powershell
touch ~/.local/dotfiles/powershell/profile.ps1
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
mkdir -p ~/.local/dotfiles/tmux
touch ~/.local/dotfiles/tmux/tmux.conf
##########################################
# vscode
##########################################
mkdir -p ~/.config/Code/User
# ln -fsv $PWD/vscode/settings.json ~/.config/Code/User/settings.json
# ln -fsv $PWD/vscode/keybindings.json ~/.config/Code/User/keybindings.json
cp $PWD/vscode/settings.json ~/.config/Code/User/settings.json
cp $PWD/vscode/keybindings.json ~/.config/Code/User/keybindings.json
##########################################
# bash
##########################################
# ln -fsv $PWD/bash/bashrc ~/.bashrc
# ln -fsv $PWD/bash/bash_profile ~/.bash_profile
