[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $projectRoot 'config\environment.json'
$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

if (-not (Test-Path -LiteralPath $config.worldBuilderExecutable -PathType Leaf)) {
    throw "World Builder not found: $($config.worldBuilderExecutable). Update config\environment.json first."
}

Start-Process -FilePath $config.worldBuilderExecutable -WorkingDirectory $config.gameRoot -WindowStyle Normal
