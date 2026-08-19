[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$LayoutPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'workspace\maps\2p_codex_crossroads\layout.json')
)

$ErrorActionPreference = 'Stop'
$layout = Get-Content -LiteralPath $LayoutPath -Raw -Encoding UTF8 | ConvertFrom-Json
$failures = [System.Collections.Generic.List[string]]::new()

function Test-InBounds {
    param($Point, $Area)
    return $Point.x -ge $Area.minX -and $Point.x -le $Area.maxX -and $Point.z -ge $Area.minZ -and $Point.z -le $Area.maxZ
}

function Test-RotationalPairing {
    param([object[]]$Points, [string]$Label)
    foreach ($point in $Points) {
        $pair = $Points | Where-Object { $_.x -eq -$point.x -and $_.z -eq -$point.z } | Select-Object -First 1
        if (-not $pair) {
            $failures.Add("$Label point '$($point.id)' has no 180-degree pair.")
        }
    }
}

$expectedCounts = @{
    starts = 2
    victoryPoints = 3
    fuelPoints = 2
    munitionPoints = 2
    territoryPoints = 10
    lanes = 3
}

foreach ($entry in $expectedCounts.GetEnumerator()) {
    $actual = @($layout.($entry.Key)).Count
    if ($actual -ne $entry.Value) {
        $failures.Add("$($entry.Key): expected $($entry.Value), found $actual.")
    }
}

$allPointGroups = @('starts', 'victoryPoints', 'fuelPoints', 'munitionPoints', 'territoryPoints')
foreach ($group in $allPointGroups) {
    foreach ($point in @($layout.$group)) {
        if (-not (Test-InBounds -Point $point -Area $layout.playableArea)) {
            $failures.Add("$group point '$($point.id)' is outside the playable area.")
        }
    }
}

foreach ($zone in @($layout.combatZones)) {
    if (-not (Test-InBounds -Point $zone.center -Area $layout.playableArea)) {
        $failures.Add("Combat zone '$($zone.id)' is outside the playable area.")
    }
    if ($zone.lane -notin @($layout.lanes.id)) {
        $failures.Add("Combat zone '$($zone.id)' references an unknown lane '$($zone.lane)'.")
    }
}

foreach ($landmark in @($layout.landmarks)) {
    if (-not (Test-InBounds -Point $landmark -Area $layout.playableArea)) {
        $failures.Add("Landmark '$($landmark.id)' is outside the playable area.")
    }
}

Test-RotationalPairing -Points @($layout.starts) -Label 'Start'
Test-RotationalPairing -Points @($layout.victoryPoints) -Label 'Victory'
Test-RotationalPairing -Points @($layout.fuelPoints) -Label 'Fuel'
Test-RotationalPairing -Points @($layout.munitionPoints) -Label 'Munition'
Test-RotationalPairing -Points @($layout.territoryPoints) -Label 'Territory'

if (@($layout.starts | Select-Object -ExpandProperty player -Unique).Count -ne 2) {
    $failures.Add('Starts must use two distinct player assignments.')
}

if (@($layout.starts | Select-Object -ExpandProperty team -Unique).Count -ne 2) {
    $failures.Add('Starts must use two distinct team assignments.')
}

foreach ($lane in @($layout.lanes)) {
    if (@($lane.points).Count -lt 2) {
        $failures.Add("Lane '$($lane.id)' has fewer than two planning points.")
    }
    foreach ($point in @($lane.points)) {
        if (-not (Test-InBounds -Point $point -Area $layout.playableArea)) {
            $failures.Add("Lane '$($lane.id)' exits the playable area.")
        }
    }
}

$summary = [pscustomobject]@{
    Scenario = $layout.scenarioName
    Status = $layout.status
    Starts = @($layout.starts).Count
    VictoryPoints = @($layout.victoryPoints).Count
    FuelPoints = @($layout.fuelPoints).Count
    MunitionPoints = @($layout.munitionPoints).Count
    TerritoryPoints = @($layout.territoryPoints).Count
    Lanes = @($layout.lanes).Count
    Failures = $failures.Count
}

$summary | Format-List
if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output 'Planning layout checks passed. This does not validate an SGB or runtime playability.'
exit 0
