#!/usr/bin/env -S pwsh -NoLogo -NonInteractive -NoProfile
##########################################
# powershell
##########################################
Install-Module PSFzf
New-Item -type dir ~/.config/powershell -force | Out-Null
ln -fsv $PSScriptRoot/powershell/profile.ps1 ~/.config/powershell/profile.ps1
##########################################
# vim
##########################################
ln -fsv $PSScriptRoot/vim/.vimrc ~/.vimrc
##########################################
# tmux
##########################################
ln -fsv $PSScriptRoot/tmux/.tmux.conf ~/.tmux.conf
##########################################
# vscode
##########################################
New-Item -type dir ~/.config/Code/User -force | Out-Null
if (-not (Test-Path ~/.config/Code/User/settings.json)) { Copy-Item $PSScriptRoot/vscode/settings.json ~/.config/Code/User/settings.json }
if (-not (Test-Path ~/.config/Code/User/keybindings.json)) { Copy-Item $PSScriptRoot/vscode/keybindings.json ~/.config/Code/User/keybindings.json }
##########################################
# bash
##########################################
# ln -fsv $PSScriptRoot/bash/bashrc ~/.bashrc
# ln -fsv $PSScriptRoot/bash/bash_profile ~/.bash_profile
##########################################
# claude
##########################################
New-Item -type dir ~/.claude -force | Out-Null
if (-not (Test-Path ~/.claude/settings.json)) { Copy-Item $PSScriptRoot/claude/settings.json ~/.claude/settings.json }
if (-not (Test-Path ~/.claude.json)) { Copy-Item $PSScriptRoot/claude/claude.json ~/.claude.json }
