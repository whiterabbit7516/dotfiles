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
Set-PSReadLineOption -EditMode Vi -ViModeIndicator Cursor;
Write-Host -NoNewline "`e[3 q" # Force the initial cursor shape, since PSReadLine won't fire the mode-change handler on startup (no transition has occurred yet)
Set-PSReadLineKeyHandler -Chord Ctrl+c -Function ViCommandMode;
Set-PSReadLineOption -PredictionViewStyle ListView;
Set-PSReadLineOption -BellStyle None;
Set-PSReadLineOption -HistorySearchCaseSensitive;
Set-PSReadLineOption -AddToHistoryHandler {
  param([string]$line)
  $trimmed = $line.TrimStart().TrimEnd();
  if ($trimmed.Length -eq 0) {
    return $false
  }
  # # Only add to history if the line ends with a semicolon
  # return ($trimmed[-1] -eq ';')
  return $true
};
function Wipe-History {
  Clear-History; # delete current PSReadLine session history
  [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory(); # delete current console session history
  Remove-Item $(Get-PSReadLineOption).HistorySavePath; # delete PSReadLine history file
};
function Edit-History {
  code -r $(Get-PSReadLineOption).HistorySavePath;
};
#########################################
# PowerShell Profile
#########################################
function Edit-PSProfile {
  code -r $PROFILE.CurrentUserAllHosts;
};
#########################################
# Read-EnvFile
#########################################
function Read-EnvFile {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$path
  )
  Get-Content -Path $path | ForEach-Object {
    $line = $_.Trim();
    if ($line -eq "" -or $line.StartsWith("#")) {
      return;
    }
    $key, $value = $line -split "=", 2;
    if ($value.Length -ge 2 -and $value[0] -eq $value[-1] -and ($value[0] -eq '"' -or $value[0] -eq "'")) {
      $value = $value.Substring(1, $value.Length - 2);
    }
    [System.Environment]::SetEnvironmentVariable($key, $value);
    Write-Verbose "$key=$value";
  }
}
#########################################
# Copy-Location
#########################################
function Copy-Location {
  if (-not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Warning "tmux is not available on PATH.";
    return;
  }
  try {
    Invoke-Native tmux -- list-sessions 2>&1 | Out-Null;
  }
  catch {
    Write-Warning "tmux server is not running.";
    return;
  }
  $location = Get-Location | Select-Object -ExpandProperty Path;
  Invoke-Native tmux -- set-buffer $location;
  Invoke-Native tmux -- set-buffer -b "location" $location;
  $message = "path copied to tmux buffer: $location"
  Write-Host $message;
  Invoke-Native tmux -- display-message -d 1000 $message;
}
Set-Alias -Name cl -Value 'Copy-Location';
#########################################
# Invoke-Native
#########################################
function Invoke-Native {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$command,
 
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$arguments
  )
 
  & $command @arguments;
  if ($LASTEXITCODE -ne 0) {
    throw "'$command $($arguments -join ' ')' failed with exit code $LASTEXITCODE";
  }
}
#########################################
# tmux 
#########################################
# separator windows that segregate the window list into groups
$tmux_separator_windows = @('⚫⚫⚫⚫', '⚫⚫⚫⚫🟢🟢🟢🟢', '🟢🟢🟢🟢🟡🟡🟡🟡', '🟡🟡🟡🟡🟠🟠🟠🟠', '🟠🟠🟠🟠🔵🔵🔵🔵', '🔵🔵🔵🔵⚪⚪⚪⚪', '⚪⚪⚪⚪');
function Edit-TmuxConfig {
  code -r $HOME/.tmux.conf;
}
function Start-TmuxSession {
  if (-not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Warning "tmux is not available on PATH.";
    return;
  }
  $server_running = $true;
  try {
    Invoke-Native tmux -- list-sessions 2>&1 | Out-Null;
  }
  catch {
    $server_running = $false;
  }
  if (-not $server_running) {
    Invoke-Native tmux -- new-session;
    return;
  }
  if ([string]::IsNullOrWhiteSpace($ENV:TMUX)) {
    Invoke-Native tmux -- attach-session;
    return;
  }
  # already inside tmux; attach-session would fail in nested mode
  $target = (Invoke-Native tmux -- list-sessions -F '#S' | Select-Object -First 1);
  if ([string]::IsNullOrWhiteSpace($target)) {
    Write-Warning "no tmux session found to switch to.";
    return;
  }
  Invoke-Native tmux -- switch-client -t $target;
}
function Initialize-TmuxWindows {
  if (-not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Warning "tmux is not available on PATH.";
    return;
  }
  if ([string]::IsNullOrWhiteSpace($ENV:TMUX)) {
    Write-Warning "must be inside tmux to initialize windows.";
    return;
  }
  try {
    Invoke-Native tmux -- list-sessions 2>&1 | Out-Null;
  }
  catch {
    Write-Warning "tmux server is not running.";
    return;
  }
  $tmux_separator_windows | ForEach-Object {
    $window_name = $_;
    Invoke-Native tmux -- new-window -n $window_name;
    Invoke-Native tmux -- clock-mode -t $window_name;
    Invoke-Native tmux -- select-pane -t $window_name -d;
  }
}
function Sort-TmuxWindows {
  if (-not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Warning "tmux is not available on PATH.";
    return;
  }
  if ([string]::IsNullOrWhiteSpace($ENV:TMUX)) {
    Write-Warning "must be inside tmux to sort windows.";
    return;
  }
  try {
    Invoke-Native tmux -- list-sessions 2>&1 | Out-Null;
  }
  catch {
    Write-Warning "tmux server is not running.";
    return;
  }
  # non-ASCII rather than \p{So}: .NET regex matches UTF-16 units, so astral emoji never match a symbol class
  function Test-TmuxSeparator {
    param([string]$Name)
    return ($tmux_separator_windows -contains $Name) -or (($Name -match '[^\x00-\x7F]') -and ($Name -notmatch '[\p{L}\p{N}]'));
  }
  function Get-TmuxNaturalKey {
    param([string]$Name)
    $key = '';
    foreach ($chunk in [regex]::Matches($Name.ToLowerInvariant(), '\d+|\D+')) {
      if ($chunk.Value -match '^\d+$') { $key += $chunk.Value.PadLeft(12, '0'); } else { $key += $chunk.Value; }
    }
    return $key;
  }

  $session = Invoke-Native tmux -- display-message -p '#S';
  $base_index = [int](((Invoke-Native tmux -- show-options -t $session -g base-index) -split '\s+')[-1]);
  $windows = Invoke-Native tmux -- list-windows -t $session -F '#{window_id}|#{window_index}|#{window_name}' | ForEach-Object {
    $id, $index, $name = $_ -split '\|', 3;
    [pscustomobject]@{ Id = $id; Index = [int]$index; Name = $name; IsSeparator = (Test-TmuxSeparator $name); };
  } | Sort-Object Index;

  # sort each run of windows between separators; separators keep their relative order
  $ordered = [System.Collections.Generic.List[object]]::new();
  $group = [System.Collections.Generic.List[object]]::new();
  foreach ($window in $windows) {
    if (-not $window.IsSeparator) {
      $group.Add($window);
      continue;
    }
    $group | Sort-Object { Get-TmuxNaturalKey $_.Name } | ForEach-Object { $ordered.Add($_); };
    $group.Clear();
    $ordered.Add($window);
  }
  $group | Sort-Object { Get-TmuxNaturalKey $_.Name } | ForEach-Object { $ordered.Add($_); };

  for ($i = 0; $i -lt $ordered.Count; $i++) {
    $ordered[$i] | Add-Member -NotePropertyName NewIndex -NotePropertyValue ($base_index + $i) -Force;
  }
  $moved = @($ordered | Where-Object { $_.Index -ne $_.NewIndex });
  if ($moved.Count -eq 0) {
    Write-Host "tmux windows are already sorted.";
    return;
  }

  # park above the occupied range in final order, then bring each back down so no move lands on a taken index
  $active_id = Invoke-Native tmux -- display-message -t $session -p '#{window_id}';
  $staging = (($windows.Index | Measure-Object -Maximum).Maximum) + 1000;
  for ($i = 0; $i -lt $ordered.Count; $i++) {
    Invoke-Native tmux -- move-window -s $ordered[$i].Id -t "${session}:$($staging + $i)";
  }
  foreach ($window in $ordered) {
    Invoke-Native tmux -- move-window -s $window.Id -t "${session}:$($window.NewIndex)";
  }
  Invoke-Native tmux -- select-window -t $active_id;
  Write-Host "sorted $($ordered.Count) tmux windows, $($moved.Count) moved.";
}
function Store-TmuxCommand {
  param(
    [Parameter(Mandatory = $true, HelpMessage = "command to be executed")]
    [ValidateNotNullOrWhiteSpace()]
    [string]$Command,
    [Parameter(Mandatory = $false, HelpMessage = "store the command without executing it")]
    [switch]$NoExecute
  )
  if (-not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Warning "tmux is not available on PATH.";
    return;
  }
  try {
    Invoke-Native tmux -- list-sessions 2>&1 | Out-Null;
  }
  catch {
    Write-Warning "tmux server is not running.";
    return;
  }
  $location = Get-Location | Select-Object -ExpandProperty Path;
  $pane_title = " $location · $Command "; # store the cwd & cmd in pane_title
  Invoke-Native tmux -- select-pane -T $pane_title;
  if (-not $NoExecute) {
    Invoke-Expression $Command;
  }
}
Set-Alias -Name sb -Value 'Store-TmuxCommand';
function Restore-TmuxCommand {
  if (-not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Warning "tmux is not available on PATH.";
    return;
  }
  try {
    Invoke-Native tmux -- list-sessions 2>&1 | Out-Null;
  }
  catch {
    Write-Warning "tmux server is not running.";
    return;
  }
  $pane_title = Invoke-Native tmux -- display-message -p '#{pane_title}'; # restore the cwd & cmd from pane_title
  if ([string]::IsNullOrWhiteSpace($pane_title)) {
    Write-Warning "pane title is empty; nothing to restore.";
    return;
  }
  $parts = $pane_title.Trim() -split ' \· ', 2; # parse out the location and command
  if ($parts.Count -ne 2) {
    Write-Warning "pane title is not in the expected '<location> · <command>' format: $pane_title";
    return;
  }
  $location, $Command = $parts;
  if ([string]::IsNullOrWhiteSpace($location) -or [string]::IsNullOrWhiteSpace($Command)) {
    Write-Warning "parsed an empty location or command from pane title: $pane_title";
    return;
  }
  if (-not (Test-Path -LiteralPath $location)) {
    Write-Warning "parsed location does not exist: $location";
    return;
  }
  Set-Location -LiteralPath $location;
  Invoke-Expression $Command;
}
Set-Alias -Name rb -Value 'Restore-TmuxCommand';
function Get-TmuxPaneId {
  if (-not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Warning "tmux is not available on PATH.";
    return;
  }
  try {
    Invoke-Native tmux -- list-sessions 2>&1 | Out-Null;
  }
  catch {
    Write-Warning "tmux server is not running.";
    return;
  }
  $pane_id = Invoke-Native tmux -- display-message -p '#{session_id}:#{window_id}.#{pane_id}'
  if ([string]::IsNullOrWhiteSpace($pane_id)) {
    Write-Warning "failed to retrieve pane id.";
    return;
  }
  return $pane_id;
}
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
function Get-GitRef {
  $errorpattern = "^(fatal|error)\:.+$";
  $branchpattern = "^.+branch (?<branch>.+)$";
  $commitpattern = "^.+detached at (?<commit>.+)$";
  $tagpattern = "^.+tag (?<tag>.+)$";
  $r = iex "/usr/local/bin/git status 2>&1" -ErrorAction SilentlyContinue;
  if (-not $?) {
    return $null;
  }
  if ($r -eq $null) {
    return $null;
  }
  foreach ($line in $r) {
    if ($line -eq $null) {
      continue;
    }
    if ($line.GetType().Name -ne "String") {
      continue;
    }
    # elseif ($line -match $errorpattern)
    # {
    #     continue;
    # }
    elseif ($line -match $branchpattern) {
      return $Matches["branch"];
    }
    elseif ($line -match $commitpattern) {
      return $Matches["commit"];
    }
    elseif ($line -match $tagpattern) {
      return $Matches["tag"];
    }
  }
  return $null;
}
function prompt {
  $username = $ENV:USER ?? $(whoami);
  $hostname = $ENV:HOST ?? $(hostname);
  $gitbranch = $(Get-GitRef) ?? "●";
  $path = Get-Location # | Split-Path -Leaf
  $promptcontext = "│ $username │ $hostname │ $gitbranch │ $path │";
  $promptwidth = $promptcontext.Length;
  $promptprefix = "➜  ";
  $promptbordertop = "┌" + $("─" * ($promptwidth - 2)) + "┐";
  $promptborderbottom = "└" + $("─" * ($promptwidth - 2)) + "┘";
  $prompt = $promptbordertop + "`n" + $promptcontext + "`n" + $promptborderbottom + "`n" + $promptprefix;
  return $prompt;
}
#########################################
# .local/powershell/profile.ps1
#########################################
if (Test-Path ~/.local/dotfiles/powershell/profile.ps1) {
  Write-Information "Reading ~/.local/dotfiles/powershell/profile.ps1";
  Invoke-Expression -Command ~/.local/dotfiles/powershell/profile.ps1;
}
# read from home .env
if (Test-Path ~/.env) {
  Read-EnvFile /root/.env;
}
# read from cwd .env
if (Test-Path .env) {
  Read-EnvFile .env;
}
