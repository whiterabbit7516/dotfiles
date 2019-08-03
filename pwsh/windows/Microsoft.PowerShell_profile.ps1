#########################################
# aliases
#########################################
Set-Alias -Name vscode -Value '/usr/bin/code'
#########################################
# paths
#########################################
# $env:Path += ';C:\Program Files\Sublime Text 3\';
# $env:Path += ';C:\Program Files (x86)\Microsoft Visual Studio\Preview\Community\Common7\IDE\';
# $env:Path += ';C:\Program Files (x86)\Atlassian\SourceTree\';
# $env:Path += ';C:\Users\xanthos954\AppData\Roaming\Spotify\';
# $env:Path += ';C:\Users\xanthos954\AppData\Local\Programs\Fiddler\';
# #$env:Path += ';C:\Users\xanthos954\programs\java\jdk-10.0.2\bin\';
# $env:Path += ';C:\Program Files\nodejs';
# $env:Path += ';%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe';
# $env:Path += ';C:\Users\xanthos954\.cargo\bin\';
# $env:Path += ';C:\Users\xanthos954\programs\CredentialProviderBundle\';
# $env:Path += ';C:\Users\xanthos954\AppData\Roaming\Python\Python37\Scripts\';
# $env:Path += ';C:\ProgramData\chocolatey\bin\';
if (Test-Path $HOME/programs -PathType Container) {
    Get-ChildItem -Recurse -Path "$HOME/programs" -Include "bin" -Directory | % { $env:Path += ";$($_.FullName)" }
}
#########################################
# variables
#########################################
# $malachite = 'C:\Users\xanthos954\projects\malachite';
# $jungle = 'C:\Users\xanthos954\projects\malachite\projects\Jungle';
# $hydra = 'C:\Users\xanthos954\projects\malachite\projects\Hydra';
# $roxyblox = 'C:\Users\xanthos954\projects\malachite\projects\Roxyblox';
# $mamba = 'C:\Users\xanthos954\projects\malachite\projects\Hydra\Hydra.Server.Mamba';
# $blackrat = 'C:\Users\xanthos954\projects\CRYZ0B9T\projects\CRYZ0B9T.Client.BlackRat';
# $whiterat = 'C:\Users\xanthos954\projects\CRYZ0B9T\projects\CRYZ0B9T.Client.WhiteRat';
# $brownrat = 'C:\Users\xanthos954\projects\CRYZ0B9T\projects\CRYZ0B9T.Client.BrownRat';
# $gnastystream = 'C:\Users\xanthos954\projects\malachite\projects\GnastyStream';
# $microsoftsdkspath = 'C:\Program Files\Microsoft SDKs';
#########################################
# Set environment properties
$ui = (Get-Host).UI.RawUI;
$ui.BackgroundColor = "Black"
$ui.ForegroundColor = "DarkCyan"

# Set prompt
function prompt {
    $path = Get-Location | Split-Path -Leaf
    # $prompt = "> $([System.DateTime]::UtcNow.ToString("HH:mm:ss")) | $path >> "
    $prompt = "> $(hostname) | $path >> "
    return $prompt
}

Import-Module posh-git