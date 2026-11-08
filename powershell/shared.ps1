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
