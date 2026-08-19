[CmdletBinding()]
param(
    [string]$ScenarioName = '2p_codex_crossroads',
    [string]$TargetRoot,
    [switch]$Overwrite
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $projectRoot 'config\environment.json'

if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw "Environment config not found: $configPath"
}

$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$sourceRoot = Join-Path $projectRoot "workspace\maps\$ScenarioName\scenario"
if (-not $TargetRoot) {
    $TargetRoot = Join-Path $config.gameRoot 'CoH2\Data\Scenarios'
}

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Scenario source directory not found: $sourceRoot"
}
if (-not (Test-Path -LiteralPath $TargetRoot -PathType Container)) {
    throw "World Builder scenario directory not found: $TargetRoot"
}

$fileNames = @(
    "$ScenarioName.sgb"
    "$ScenarioName.info"
    "$ScenarioName.options"
    "$ScenarioName.scenariomarker"
    "${ScenarioName}_ID.scar"
    "${ScenarioName}_lao.dds"
    "${ScenarioName}_mm.tga"
    "${ScenarioName}_tdm.dds"
)

$missingSources = @(
    foreach ($fileName in $fileNames) {
        $sourcePath = Join-Path $sourceRoot $fileName
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            $sourcePath
        }
    }
)
if ($missingSources.Count -gt 0) {
    throw "Scenario bundle is incomplete. Missing source files:`n$($missingSources -join "`n")"
}

$plan = foreach ($fileName in $fileNames) {
    $sourcePath = Join-Path $sourceRoot $fileName
    $targetPath = Join-Path $TargetRoot $fileName
    $targetExists = Test-Path -LiteralPath $targetPath -PathType Leaf
    $sameContent = $false

    if ($targetExists) {
        $sourceHash = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash
        $targetHash = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash
        $sameContent = $sourceHash -eq $targetHash
    }

    [pscustomobject]@{
        Name = $fileName
        Source = $sourcePath
        Target = $targetPath
        Action = if (-not $targetExists) {
            'INSTALL'
        }
        elseif ($sameContent) {
            'SKIP_IDENTICAL'
        }
        elseif ($Overwrite) {
            'REPLACE'
        }
        else {
            'REFUSE_DIFFERENT'
        }
    }
}

$refused = @($plan | Where-Object Action -eq 'REFUSE_DIFFERENT')
if ($refused.Count -gt 0) {
    $refusedNames = $refused.Name -join ', '
    throw "Target contains different scenario files: $refusedNames. Re-run with -Overwrite only after confirming replacement."
}

foreach ($item in $plan | Where-Object Action -in @('INSTALL', 'REPLACE')) {
    Copy-Item -LiteralPath $item.Source -Destination $item.Target -Force:$Overwrite
}

$plan | Select-Object Name, Action, Target | Format-Table -AutoSize
Write-Output "Scenario bundle ready: $TargetRoot"
