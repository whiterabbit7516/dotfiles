#########################################
# aliases
#########################################
if ($(get-command code -ErrorAction SilentlyContinue) -ne $null)
{
  Set-Alias -Name vscode -Value 'code'
}
elseif ($(get-command code-insiders -ErrorAction SilentlyContinue) -ne $null)
{
  Set-Alias -Name vscode -Value 'code-insiders'
}
#########################################
# environment variables
#########################################
# $ENV:PYTHONSTARTUP="/home/.../.pythonrc.py"
#########################################
# paths
#########################################
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
Set-PSReadLineOption -EditMode Vi -ViModeIndicator Cursor
Set-PSReadLineKeyHandler -Chord Ctrl+c -Function ViCommandMode
#########################################
# FZF
#########################################
Import-Module PSFzf -ArgumentList 'Ctrl+t','Ctrl+r' -ErrorAction SilentlyContinue
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-Alias -Name fe -Value 'Invoke-FuzzyEdit'
Set-Alias -Name fd -Value 'Invoke-FuzzySetLocation'
Set-Alias -Name fh -Value 'Invoke-FuzzyHistory'
#########################################
# PoshGit
#########################################
# Import-Module posh-git -ErrorAction SilentlyContinue
# if ($?)
# {
#     $GitPromptSettings.DefaultForegroundColor = [ConsoleColor]::Magenta
#     $GitPromptSettings.DefaultPromptPrefix = "`$ENV:USER@`$(hostname) "
#     # $GitPromptSettings.DefaultPromptPath = "`$(Get-Location | Split-Path -Leaf)"
#     $GitPromptSettings.DefaultPromptSuffix = " `n■ ■ ■ "
# }
#########################################
# Prompt
#########################################
# else
# {
$HOST.UI.RawUI.ForegroundColor = 6
function prompt {
  $path = Get-Location # | Split-Path -Leaf
  $username = $ENV:USER ?? $(whoami)
  $hostname = $ENV:HOST ?? $(hostname)
  $prompt = "$username | $hostname | $path`n■ ■ ■ "
  return $prompt
}
# }
#########################################
# VPN
#########################################
$nordvpn = get-command nordvpn -ErrorAction SilentlyContinue
if ($nordvpn -ne $null)
{
  nordvpn status | select-string -Pattern "Status|IP|server" -NoEmphasis
}
else
{
  Write-Warning "VPN Unavailable"
}
#########################################
# .local/powershell/profile.ps1
#########################################
if (Test-Path ~/.local/dotfiles/powershell/profile.ps1)
{
  Write-Information "Reading ~/.local/dotfiles/powershell/profile.ps1"
  Invoke-Expression -Command ~/.local/dotfiles/powershell/profile.ps1
}
#########################################
