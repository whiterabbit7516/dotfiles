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
    $GitPromptSettings.DefaultPromptPrefix = "`$ENV:USER@`$(hostname) | "
    $GitPromptSettings.DefaultPromptPath = "`$(Get-Location | Split-Path -Leaf)"
    $GitPromptSettings.DefaultPromptSuffix = " > "
}
else 
{
    function prompt {
        $path = Get-Location | Split-Path -Leaf
        $prompt = "[$ENV:USER@$(hostname)] $path > "
        return $prompt
    }
}