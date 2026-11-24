$ErrorActionPreference = 'Stop'

function Invoke-Docker {
  & docker @args

  if ($LASTEXITCODE -ne 0) {
    throw "docker $($args -join ' ') failed with exit code $LASTEXITCODE"
  }
}

Invoke-Docker pull ghcr.io/whiterabbit7516/devcontainers/devenv-main-arm64:latest
Invoke-Docker volume create devcontainer-whiterabbit7516-dotfiles-data

$directories = @(
  '.aws', 
  '.claude', 
  '.config', 
  '.copilot', 
  '.gnupg', 
  '.local',
  '.ssh', 
  '.tmux', 
  '.tsh', 
  'repos', 
  'repos/whiterabbit7516', 
  'scratch'
)

$files = @(
  '.claude.json',
  '.env',
  '.gitconfig',
  'z-location.db'
)

foreach ($directory in $directories) {
  Invoke-Docker run --rm -v 'devcontainer-whiterabbit7516-dotfiles-data:/seed' busybox sh -c "mkdir -p /seed/$directory"
}

foreach ($file in $files) {
  Invoke-Docker run --rm -v 'devcontainer-whiterabbit7516-dotfiles-data:/seed' busybox sh -c "[ -f /seed/$file ] || touch /seed/$file"
}
