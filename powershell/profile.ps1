#########################################
# aliases
#########################################
Set-Alias -Name vscode -Value 'code'
#########################################
# paths
#########################################

#########################################

# Set prompt
Import-Module posh-git -ErrorAction SilentlyContinue

if ($?)
{
    $GitPromptSettings.DefaultForegroundColor = [ConsoleColor]::Magenta
    $GitPromptSettings.DefaultPromptPrefix = "`$ENV:USER@`$(hostname) "
    # $GitPromptSettings.DefaultPromptPath = "`$(Get-Location | Split-Path -Leaf)"
    $GitPromptSettings.DefaultPromptSuffix = " `n>>> "
}
else 
{
    function prompt {
        $path = Get-Location | Split-Path -Leaf
        $prompt = "[$ENV:USER@$(hostname)] $path > "
        return $prompt
    }
}