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
$ENV:PATH = "$($ENV:PATH):/root/.cargo/bin/"
$ENV:PATH = "$($ENV:PATH):/root/.krew/bin/"
$ENV:PATH = "$($ENV:PATH):/root/.nargo/bin/"
$ENV:PATH = "$($ENV:PATH):/root/.bb/"
$ENV:PATH = "$($ENV:PATH):/usr/local/go/bin/"
$ENV:PATH = "$($ENV:PATH):/usr/local/foundry/"
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
Set-PSReadLineOption -EditMode Vi -ViModeIndicator Cursor;
Set-PSReadLineKeyHandler -Chord Ctrl+c -Function ViCommandMode;
Set-PSReadLineOption -PredictionViewStyle ListView;
#########################################
# fzf
#########################################
Import-Module PSFzf -ArgumentList 'Ctrl+t','Ctrl+r' -ErrorAction SilentlyContinue
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-Alias -Name fe -Value 'Invoke-FuzzyEdit'
Set-Alias -Name fd -Value 'Invoke-FuzzySetLocation'
Set-Alias -Name fh -Value 'Invoke-FuzzyHistory'
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
function get-gitbranch {
    $errorpattern = "^(fatal|error)\:.+$";
    $branchpattern = "^.+branch (?<branch>.+)$";
    $commitpattern = "^.+detached at (?<commit>.+)$";
    $tagpattern = "^.+tag (?<tag>.+)$";
    $r = iex "/usr/local/bin/git status 2>&1" -ErrorAction SilentlyContinue;
    if (-not $?)
    {
        return $null;
    }
    if ($r -eq $null)
    {
        return $null;
    }
    foreach ($line in $r) 
    {
        if ($line -eq $null)
        {
            continue;
        }
        if ($line.GetType().Name -ne "String")
        {
            continue;
        }
        # elseif ($line -match $errorpattern)
        # {
        #     continue;
        # }
        elseif ($line -match $branchpattern)
        {
            return $Matches["branch"];
        }
        elseif ($line -match $commitpattern)
        {
            return $Matches["commit"];
        }
        elseif ($line -match $tagpattern)
        {
            return $Matches["tag"];
        }
    }
    return $null;
}
function prompt {
  $path = Get-Location # | Split-Path -Leaf
  $username = $ENV:USER ?? $(whoami);
  $hostname = $ENV:HOST ?? $(hostname);
  $gitbranch = get-gitbranch ?? "????";
  if ($gitbranch -eq $null) { $gitbranch = "????"; }
  $promptcontext = "■ $username | $hostname | $gitbranch | $path ■";
  $promptwidth = $promptcontext.Length;
  $promptprefix = "■■■▶ ";
  $promptbordertop = "■" * $promptwidth;
  $promptborderbottom = "■" + $("-" * ($promptwidth - 2)) + "■";
  $prompt = $promptbordertop + "`n" + $promptcontext + "`n" + $promptborderbottom + "`n" + $promptprefix;
  return $prompt;
}
#########################################
# .local/powershell/profile.ps1
#########################################
if (Test-Path ~/.local/dotfiles/powershell/profile.ps1)
{
  Write-Information "Reading ~/.local/dotfiles/powershell/profile.ps1";
  Invoke-Expression -Command ~/.local/dotfiles/powershell/profile.ps1;
}
#########################################
