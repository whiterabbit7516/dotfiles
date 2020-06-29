#########################################
# aliases
#########################################
if ($(command code -ErrorAction SilentlyContinue) -ne $null)
{
  Set-Alias -Name vscode -Value 'code'
}
elseif ($(command code-insiders -ErrorAction SilentlyContinue) -ne $null)
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
#########################################
# PoshGit
#########################################
# Import-Module posh-git -ErrorAction SilentlyContinue
# if ($?)
# {
#     $GitPromptSettings.DefaultForegroundColor = [ConsoleColor]::Magenta
#     $GitPromptSettings.DefaultPromptPrefix = "`$ENV:USER@`$(hostname) "
#     # $GitPromptSettings.DefaultPromptPath = "`$(Get-Location | Split-Path -Leaf)"
#     $GitPromptSettings.DefaultPromptSuffix = " `n■ "
# }
#########################################
# VPN
#########################################
$nordvpn = command nordvpn -ErrorAction SilentlyContinue
if ($nordvpn -ne $null)
{
  nordvpn status | select-string -Pattern "Status|IP|server" -NoEmphasis
}
else
{
  Write-Warning "VPN Unavailable"
}
#########################################
# Prompt
#########################################
$HOST.UI.RawUI.ForegroundColor = 6
function prompt {
  $path = Get-Location # | Split-Path -Leaf
  $prompt = "[$ENV:USER@$(hostname)] $path`n■ ■ ■ "
  return $prompt
}
#########################################
# .local/powershell/profile.ps1
#########################################
if (Test-Path ~/local/etc/powershell/profile.ps1)
{
  Write-Information "Reading ~/local/etc/powershell/profile.ps1"
  Invoke-Expression -Command ~/local/etc/powershell/profile.ps1
}
#########################################
