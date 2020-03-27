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

# FZF
Import-Module PSFzf -ArgumentList 'Ctrl+t','Ctrl+r' -ErrorAction SilentlyContinue

# Set prompt
Import-Module posh-git -ErrorAction SilentlyContinue

if ($?)
{
    $GitPromptSettings.DefaultForegroundColor = [ConsoleColor]::Magenta
    $GitPromptSettings.DefaultPromptPrefix = "`$ENV:USER@`$(hostname) "
    # $GitPromptSettings.DefaultPromptPath = "`$(Get-Location | Split-Path -Leaf)"
    $GitPromptSettings.DefaultPromptSuffix = " `n■ "
}
else 
{
    function prompt {
        $path = Get-Location | Split-Path -Leaf
        $prompt = "[$ENV:USER@$(hostname)] $path > "
        return $prompt
    }
}

# Print nordvpn status
$nordvpn = command nordvpn -ErrorAction SilentlyContinue
if ($nordvpn -ne $null)
{
  nordvpn status | select-string -Pattern "Status|IP|server" -NoEmphasis
}
