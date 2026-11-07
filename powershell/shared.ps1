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
