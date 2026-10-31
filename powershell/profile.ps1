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
function Wipe-PSHistory {
  Clear-History; # delete current PowerShell session history
  Remove-Item $(Get-PSReadLineOption).HistorySavePath; # delete PSReadLine history file
  [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory(); # clear current PSReadLine session history
};
function Edit-PSHistory {
  $filepath = (Get-PSReadLineOption).HistorySavePath;
  Write-Host "opening file $filepath ...";
  code -r $filepath;
};
function Reload-PSHistory {
  $historyPath = (Get-PSReadLineOption).HistorySavePath;
  if ([string]::IsNullOrWhiteSpace($historyPath) -or -not (Test-Path -LiteralPath $historyPath -PathType Leaf)) {
    return;
  }
  $history = Get-Content -LiteralPath $historyPath -ErrorAction Stop; # read desired history
  Remove-Item $historyPath; # delete PSReadLine history file
  [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory(); # clear the current PSReadLine session history
  # add desired history back to the current PSReadLine session & history file
  foreach ($command in $history) {
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($command);
  }
};
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
  $existing = @(Invoke-Native tmux -- list-windows -F '#{window_name}');
  $tmux_separator_windows | Where-Object { $existing -notcontains $_ } | ForEach-Object {
    $window_id = Invoke-Native tmux -- new-window -n $_ -P -F '#{window_id}';
    Invoke-Native tmux -- clock-mode -t $window_id;
    Invoke-Native tmux -- select-pane -t $window_id -d;
  }
}
# windows in these groups (indexes into $tmux_separator_windows: green, yellow, orange, blue) are kept sorted by name
$tmux_sorted_groups = @(1, 2, 3, 4);
function Get-TmuxNaturalKey {
  param([string]$Name)
  $key = '';
  foreach ($chunk in [regex]::Matches($Name.ToLowerInvariant(), '\d+|\D+')) {
    if ($chunk.Value -match '^\d+$') { $key += $chunk.Value.PadLeft(12, '0'); } else { $key += $chunk.Value; }
  }
  return $key;
}
# ordinal rather than culture-aware, so sorting and inserting always agree
function Compare-TmuxWindowName {
  param([string]$A, [string]$B)
  return [string]::CompareOrdinal((Get-TmuxNaturalKey $A), (Get-TmuxNaturalKey $B));
}
# every separator must exist exactly once, in order, or the groups can't be trusted; $null (after a warning) when they aren't
function Get-TmuxSeparators {
  param([object[]]$Windows)
  $separators = @();
  foreach ($name in $tmux_separator_windows) {
    $found = @($Windows | Where-Object { $_.Name -ceq $name });
    if ($found.Count -ne 1) {
      Write-Warning "tmux groups are malformed: expected one '$name' separator, found $($found.Count).";
      return $null;
    }
    $separators += $found[0];
  }
  for ($i = 1; $i -lt $separators.Count; $i++) {
    if ($separators[$i].Index -le $separators[$i - 1].Index) {
      Write-Warning "tmux groups are malformed: separator '$($separators[$i].Name)' is not after '$($separators[$i - 1].Name)'.";
      return $null;
    }
  }
  return ,$separators;
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
  # stable insertion sort: equal names keep their current order
  function Sort-TmuxWindowList {
    param([object[]]$Windows)
    $sorted = [System.Collections.Generic.List[object]]::new();
    foreach ($window in $Windows) {
      $at = $sorted.Count;
      while (($at -gt 0) -and ((Compare-TmuxWindowName $sorted[$at - 1].Name $window.Name) -gt 0)) { $at--; }
      $sorted.Insert($at, $window);
    }
    return $sorted.ToArray();
  }

  $session = Invoke-Native tmux -- display-message -p '#S';
  $base_index = [int](((Invoke-Native tmux -- show-options -t $session -g base-index) -split '\s+')[-1]);
  $windows = @(Invoke-Native tmux -- list-windows -t $session -F '#{window_id}|#{window_index}|#{window_name}' | ForEach-Object {
    $id, $index, $name = $_ -split '\|', 3;
    [pscustomobject]@{ Id = $id; Index = [int]$index; Name = $name; IsSeparator = (Test-TmuxSeparator $name); };
  } | Sort-Object Index);
  if ($null -eq (Get-TmuxSeparators $windows)) {
    return;
  }

  # sort each run of windows between separators, but only in the sorted groups; other runs and the separators keep their order
  $ordered = [System.Collections.Generic.List[object]]::new();
  $group = [System.Collections.Generic.List[object]]::new();
  $group_id = -1; # index of the last known separator seen, i.e. which group the current run belongs to
  $flush_group = {
    $run = if ($tmux_sorted_groups -contains $group_id) { @(Sort-TmuxWindowList $group.ToArray()) } else { $group.ToArray() };
    foreach ($member in $run) { $ordered.Add($member); }
    $group.Clear();
  };
  foreach ($window in $windows) {
    if (-not $window.IsSeparator) {
      $group.Add($window);
      continue;
    }
    & $flush_group;
    $ordered.Add($window);
    $known = [array]::IndexOf($tmux_separator_windows, $window.Name);
    if ($known -ge 0) { $group_id = $known; }
  }
  & $flush_group;

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
function Throw-TmuxWindow {
  param([string]$WindowId) # defaults to the window of the current pane
  if (-not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Warning "tmux is not available on PATH.";
    return;
  }
  if ([string]::IsNullOrWhiteSpace($ENV:TMUX)) {
    Write-Warning "must be inside tmux to throw a window.";
    return;
  }
  try {
    Invoke-Native tmux -- list-sessions 2>&1 | Out-Null;
  }
  catch {
    Write-Warning "tmux server is not running.";
    return;
  }
  $pane_target = if (-not [string]::IsNullOrWhiteSpace($WindowId)) { @('-t', $WindowId) } elseif (-not [string]::IsNullOrWhiteSpace($ENV:TMUX_PANE)) { @('-t', $ENV:TMUX_PANE) } else { @() };
  $session, $current_id = (Invoke-Native tmux -- display-message -p @pane_target '#{session_name}|#{window_id}') -split '\|', 2;
  $windows = @(Invoke-Native tmux -- list-windows -t $session -F '#{window_id}|#{window_index}|#{window_name}' | ForEach-Object {
    $id, $index, $name = $_ -split '\|', 3;
    [pscustomobject]@{ Id = $id; Index = [int]$index; Name = $name; };
  } | Sort-Object Index);

  $separators = Get-TmuxSeparators $windows;
  if ($null -eq $separators) {
    return;
  }

  # green sits between the second and third separators, yellow between the third and fourth
  $green_open, $green_close, $yellow_close = $separators[1], $separators[2], $separators[3];
  $current = $windows | Where-Object { $_.Id -eq $current_id };
  if ($null -eq $current) {
    Write-Warning "could not find the current tmux window ($current_id).";
    return;
  }
  if (($current.Index -gt $green_open.Index) -and ($current.Index -lt $green_close.Index)) {
    $from, $to, $open, $close = '🟢', '🟡', $green_close, $yellow_close;
  } elseif (($current.Index -gt $green_close.Index) -and ($current.Index -lt $yellow_close.Index)) {
    $from, $to, $open, $close = '🟡', '🟢', $green_open, $green_close;
  } else {
    Write-Warning "current tmux window '$($current.Name)' is not in the green or yellow group.";
    return;
  }

  # sorted position in the destination group: before the first window that sorts after this one, else before the separator that closes it
  $before = $windows | Where-Object { ($_.Index -gt $open.Index) -and ($_.Index -lt $close.Index) -and ((Compare-TmuxWindowName $_.Name $current.Name) -gt 0) } | Select-Object -First 1;
  if ($null -eq $before) {
    $before = $close;
  }
  Invoke-Native tmux -- move-window -b -s $current.Id -t $before.Id;
  # Write-Host "moved '$($current.Name)' $from ➔ $to";
}
function Throw-TmuxWindows {
  if (-not (Get-Command tmux -ErrorAction SilentlyContinue)) {
    Write-Warning "tmux is not available on PATH.";
    return;
  }
  if ([string]::IsNullOrWhiteSpace($ENV:TMUX)) {
    Write-Warning "must be inside tmux to throw windows.";
    return;
  }
  try {
    Invoke-Native tmux -- list-sessions 2>&1 | Out-Null;
  }
  catch {
    Write-Warning "tmux server is not running.";
    return;
  }
  $pane_target = if ([string]::IsNullOrWhiteSpace($ENV:TMUX_PANE)) { @() } else { @('-t', $ENV:TMUX_PANE) };
  $session, $current_id = (Invoke-Native tmux -- display-message -p @pane_target '#{session_name}|#{window_id}') -split '\|', 2;
  $windows = @(Invoke-Native tmux -- list-windows -t $session -F '#{window_id}|#{window_index}|#{window_name}' | ForEach-Object {
    $id, $index, $name = $_ -split '\|', 3;
    [pscustomobject]@{ Id = $id; Index = [int]$index; Name = $name; };
  } | Sort-Object Index);
  $separators = Get-TmuxSeparators $windows;
  if ($null -eq $separators) {
    return;
  }

  # the colour of the current window decides which group is thrown
  $green_open, $green_close, $yellow_close = $separators[1], $separators[2], $separators[3];
  $current = $windows | Where-Object { $_.Id -eq $current_id };
  if ($null -eq $current) {
    Write-Warning "could not find the current tmux window ($current_id).";
    return;
  }
  if (($current.Index -gt $green_open.Index) -and ($current.Index -lt $green_close.Index)) {
    $open, $close = $green_open, $green_close;
  } elseif (($current.Index -gt $green_close.Index) -and ($current.Index -lt $yellow_close.Index)) {
    $open, $close = $green_close, $yellow_close;
  } else {
    Write-Warning "current tmux window '$($current.Name)' is not in the green or yellow group.";
    return;
  }

  # each window lands at its sorted position in the other group; Throw-TmuxWindow re-reads the layout every time
  $group = @($windows | Where-Object { ($_.Index -gt $open.Index) -and ($_.Index -lt $close.Index) });
  foreach ($window in $group) {
    Throw-TmuxWindow -WindowId $window.Id;
  }
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
$ENV:TMUX_PANE_ID = Get-TmuxPaneId;
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
