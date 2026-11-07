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
