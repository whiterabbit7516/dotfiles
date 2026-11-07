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
