#########################################
# shared
#########################################
. "$PSScriptRoot/shared.ps1"
#########################################
# aliases
#########################################
if ($(get-command code -ErrorAction SilentlyContinue) -ne $null) {
  Set-Alias -Name vscode -Value 'code'
}
elseif ($(get-command code-insiders -ErrorAction SilentlyContinue) -ne $null) {
  Set-Alias -Name vscode -Value 'code-insiders'
}
function New-Directory { New-Item -Path $args[0] -ItemType Directory };
Set-Alias -Name nd -Value New-Directory;
function Get-Random4 { Get-Random -Minimum 1000 -Maximum 10000 };
Set-Alias -Name gr -Value Get-Random4;
#########################################
# environment variables
#########################################
# $ENV:PYTHONSTARTUP="/home/.../.pythonrc.py"
$ENV:ISSUES_DIR="/workspace/mount/issues/active/";
# read from home .env
if (Test-Path ~/.env) {
  Read-EnvFile /root/.env;
}
# read from cwd .env
if (Test-Path .env) {
  Read-EnvFile .env;
}
#########################################
# paths
#########################################
$ENV:PATH = "$($ENV:PATH):/root/.bb/";
$ENV:PATH = "$($ENV:PATH):/root/.cargo/bin/";
$ENV:PATH = "$($ENV:PATH):/root/.cmux/bin/";
$ENV:PATH = "$($ENV:PATH):/root/.krew/bin/";
$ENV:PATH = "$($ENV:PATH):/root/.local/bin/";
$ENV:PATH = "$($ENV:PATH):/root/.nargo/bin/";
$ENV:PATH = "$($ENV:PATH):/usr/local/foundry/";
$ENV:PATH = "$($ENV:PATH):/usr/local/go/bin/";
#########################################
# argument completers
#########################################
# # https://www.dennisroche.com/aws-cli-on-windows/ 
# Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
#   param($commandName, $wordToComplete, $cursorPosition)
#   $ENV:COMP_LINE=$wordToComplete
#   $ENV:COMP_POINT=$cursorPosition
#   aws_completer "$wordToComplete" $cursorPosition | ForEach-Object {
#       [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
#   }
# }
#########################################
# PSReadLine
#########################################
. "$PSScriptRoot/psreadline.ps1"
#########################################
# PowerShell Profile
#########################################
function Edit-PSProfile {
  $filepath = $PROFILE.CurrentUserAllHosts;
  Write-Host "opening file $filepath ...";
  code -r $filepath;
};
function Reload-PSProfile {
  . $PROFILE.CurrentUserAllHosts;
};
#########################################
# tmux 
#########################################
. "$PSScriptRoot/tmux.ps1"
#########################################
# fzf
#########################################
Import-Module PSFzf -ArgumentList 'Ctrl+t', 'Ctrl+r' -ErrorAction SilentlyContinue;
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-Alias -Name fe -Value 'Invoke-FuzzyEdit';
Set-Alias -Name fd -Value 'Invoke-FuzzySetLocation';
Set-Alias -Name fh -Value 'Invoke-FuzzyHistory';
#########################################
# colors
#########################################
# [System.Enum]::GetValues("ConsoleColor") | foreach-object {write-host $_ -ForegroundColor $_}
$Host.UI.RawUI.ForegroundColor = "DarkGray";
$PSStyle.FileInfo.Directory = $PSStyle.Foreground.Blue;
# doesnt work on mac
# $PSStyle.Formatting.CustomTableHeaderLabel = $PSStyle.Foreground.BrightGreen;
#########################################
# prompt
#########################################
. "$PSScriptRoot/prompt.ps1"
#########################################
# .local/powershell/profile.ps1
#########################################
if (Test-Path ~/.local/dotfiles/powershell/profile.ps1) {
  Write-Information "Reading ~/.local/dotfiles/powershell/profile.ps1";
  Invoke-Expression -Command ~/.local/dotfiles/powershell/profile.ps1;
}
