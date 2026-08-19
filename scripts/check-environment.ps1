[CmdletBinding()]
param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $projectRoot 'config\environment.json'

if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw "Environment config not found: $configPath"
}

$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$checks = @(
    [pscustomobject]@{ Name = 'COH2 game root'; Path = $config.gameRoot; Required = $true; Kind = 'Container' }
    [pscustomobject]@{ Name = 'World Builder'; Path = $config.worldBuilderExecutable; Required = $true; Kind = 'Leaf' }
    [pscustomobject]@{ Name = 'Archive tool'; Path = $config.archiveExecutable; Required = $true; Kind = 'Leaf' }
    [pscustomobject]@{ Name = 'User data root'; Path = $config.userDataRoot; Required = $true; Kind = 'Container' }
    [pscustomobject]@{ Name = 'Scenario root'; Path = $config.userScenarioRoot; Required = $true; Kind = 'Container' }
    [pscustomobject]@{ Name = 'Log root'; Path = $config.userLogRoot; Required = $true; Kind = 'Container' }
    [pscustomobject]@{ Name = 'Steam app manifest'; Path = $config.steamAppManifest; Required = $false; Kind = 'Leaf' }
)

$results = foreach ($check in $checks) {
    $exists = Test-Path -LiteralPath $check.Path -PathType $check.Kind
    [pscustomobject]@{
        Name = $check.Name
        Status = if ($exists) { 'OK' } elseif ($check.Required) { 'MISSING' } else { 'OPTIONAL_MISSING' }
        Required = $check.Required
        Path = $check.Path
    }
}

if ($Json) {
    $results | ConvertTo-Json -Depth 3
}
else {
    $results | Format-Table -AutoSize
}

$missingRequired = @($results | Where-Object { $_.Required -and $_.Status -ne 'OK' })
if ($missingRequired.Count -gt 0) {
    exit 1
}

exit 0
