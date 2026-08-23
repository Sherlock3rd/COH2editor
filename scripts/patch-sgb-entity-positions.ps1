param(
    [Parameter(Mandatory = $true)]
    [string]$SgbPath,

    [Parameter(Mandatory = $true)]
    [string]$PositionsJson
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SgbPath -PathType Leaf)) {
    throw "SGB not found: $SgbPath"
}

$updates = Get-Content -LiteralPath $PositionsJson -Raw | ConvertFrom-Json
if (-not $updates -or $updates.Count -eq 0) {
    throw "No entity position updates found in: $PositionsJson"
}

$bytes = [System.IO.File]::ReadAllBytes($SgbPath)
$signature = [System.Text.Encoding]::ASCII.GetString($bytes, 0, 12)
if ($signature -ne "Relic Chunky") {
    throw "Unsupported SGB signature: $signature"
}

$entityTag = [System.Text.Encoding]::ASCII.GetBytes('DATAENTI')
$entities = @{}

for ($offset = 0; $offset -le $bytes.Length - 84; $offset++) {
    if ($bytes[$offset] -ne $entityTag[0]) {
        continue
    }

    $matches = $true
    for ($i = 1; $i -lt $entityTag.Length; $i++) {
        if ($bytes[$offset + $i] -ne $entityTag[$i]) {
            $matches = $false
            break
        }
    }

    if (-not $matches) {
        continue
    }

    $entityId = [System.BitConverter]::ToUInt32($bytes, $offset + 28)
    if ($entities.ContainsKey($entityId)) {
        throw "Duplicate DATAENTI id: $entityId"
    }

    $entities[$entityId] = [pscustomobject]@{
        Offset = $offset
        BlueprintIndex = [System.BitConverter]::ToUInt32($bytes, $offset + 32)
        X = [System.BitConverter]::ToSingle($bytes, $offset + 72)
        Y = [System.BitConverter]::ToSingle($bytes, $offset + 76)
        Z = [System.BitConverter]::ToSingle($bytes, $offset + 80)
    }

    $offset += 83
}

foreach ($update in $updates) {
    $id = [uint32]$update.id
    if (-not $entities.ContainsKey($id)) {
        throw "Entity id not found: $id"
    }

    $entity = $entities[$id]
    if ($null -ne $update.blueprintIndex -and $entity.BlueprintIndex -ne [uint32]$update.blueprintIndex) {
        throw "Entity $id blueprint mismatch: expected $($update.blueprintIndex), got $($entity.BlueprintIndex)"
    }

    foreach ($axis in @('x', 'y', 'z')) {
        $expectedName = "expected$($axis.ToUpper())"
        if ($null -ne $update.$expectedName) {
            $actual = [single]$entity.$($axis.ToUpper())
            $expected = [single]$update.$expectedName
            if ([math]::Abs($actual - $expected) -gt 0.05) {
                throw "Entity $id $axis mismatch: expected $expected, got $actual"
            }
        }
    }

    $coordinates = @([single]$update.x, [single]$update.y, [single]$update.z)
    $coordinateOffsets = @(72, 76, 80)
    for ($i = 0; $i -lt 3; $i++) {
        $encoded = [System.BitConverter]::GetBytes($coordinates[$i])
        [System.Array]::Copy($encoded, 0, $bytes, $entity.Offset + $coordinateOffsets[$i], 4)
    }
}

$tempPath = "$SgbPath.codex-position-patch.tmp"
[System.IO.File]::WriteAllBytes($tempPath, $bytes)

$verifyBytes = [System.IO.File]::ReadAllBytes($tempPath)
foreach ($update in $updates) {
    $entity = $entities[[uint32]$update.id]
    $actual = @(
        [System.BitConverter]::ToSingle($verifyBytes, $entity.Offset + 72),
        [System.BitConverter]::ToSingle($verifyBytes, $entity.Offset + 76),
        [System.BitConverter]::ToSingle($verifyBytes, $entity.Offset + 80)
    )
    $expected = @([single]$update.x, [single]$update.y, [single]$update.z)
    for ($i = 0; $i -lt 3; $i++) {
        if ([math]::Abs($actual[$i] - $expected[$i]) -gt 0.001) {
            throw "Verification failed for entity $($update.id) coordinate index $i"
        }
    }
}

Move-Item -LiteralPath $tempPath -Destination $SgbPath -Force

$updates | ForEach-Object {
    [pscustomobject]@{
        Id = [uint32]$_.id
        BlueprintIndex = $entities[[uint32]$_.id].BlueprintIndex
        X = [single]$_.x
        Y = [single]$_.y
        Z = [single]$_.z
    }
}
