$ErrorActionPreference = "Stop"
##########################################
# path
##########################################

# populate path
$ENV:PATH = "$($ENV:PATH):/workspace/mount/scripts/";

##########################################
# helpers
##########################################

function Seed-File {
  param(
    [Parameter(Mandatory)]
    [string]$SourcePath,
    [Parameter(Mandatory)]
    [string]$DestinationPath
  )

  if (Test-Path -LiteralPath $DestinationPath) {
    if (-not (Test-Path -LiteralPath $DestinationPath -PathType Leaf)) {
      throw "Destination path is not a file: $DestinationPath"
    }

    if ((Get-Item -Force -LiteralPath $DestinationPath).Length -gt 0) {
      return
    }
  }

  if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
    throw "Source file not found: $SourcePath"
  }

  $destinationDirectory = [System.IO.Path]::GetDirectoryName($DestinationPath)
  if ($destinationDirectory) {
    if (-not (Test-Path -LiteralPath $destinationDirectory -PathType Container)) {
      New-Item -ItemType Directory -Path $destinationDirectory -Force -ErrorAction Stop | Out-Null
    }
  }

  Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force -ErrorAction Stop
}

##########################################
# powershell
##########################################

# fill console history
Seed-File -SourcePath "/devcontainer/resources/PSReadLine/ConsoleHost_history.txt-seed" -DestinationPath (Get-PSReadLineOption).HistorySavePath

# fzf, install only if not already present
if (-not (Get-Module -ListAvailable -Name PSFzf)) {
  pwsh -noni -nol -nop -c Install-Module -Scope AllUsers -Verbose -Force PSFzf;
}

##########################################
# git
##########################################

Seed-File -SourcePath "/workspace/mount/config/git/config-seed" -DestinationPath "/root/.gitconfig"

##########################################
# copilot
##########################################

Seed-File -SourcePath "/workspace/mount/config/copilot/settings.json-seed" -DestinationPath "/root/.copilot/settings.json"

##########################################
# claude
##########################################

Seed-File -SourcePath "/workspace/mount/config/claude/claude.json-seed" -DestinationPath "/root/.claude.json"
Seed-File -SourcePath "/workspace/mount/config/claude/settings.json-seed" -DestinationPath "/root/.claude/settings.json"

# re-install, as we mount a volume on .local
if (-not (Test-Path /root/.local/bin/claude)) {
  write-host "installing claude code...."
  curl -fsSL https://claude.ai/install.sh | bash
  /root/.local/bin/claude --version
}

##########################################
# tmux plugin manager
##########################################

# install only if not already cloned, as we mount a volume on .tmux
if (-not (Test-Path /root/.tmux/plugins/tpm)) {
  git clone --depth 1 https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm;
}
