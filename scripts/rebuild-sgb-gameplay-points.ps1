param(
    [Parameter(Mandatory = $true)] [string]$BaseSgb,
    [Parameter(Mandatory = $true)] [string]$TemplateSgb,
    [Parameter(Mandatory = $true)] [string]$LayoutJson,
    [Parameter(Mandatory = $true)] [string]$OutputSgb
)

$ErrorActionPreference = 'Stop'

function Read-U32([byte[]]$Bytes, [int]$Offset) {
    [System.BitConverter]::ToUInt32($Bytes, $Offset)
}

function Write-U32([byte[]]$Bytes, [int]$Offset, [uint32]$Value) {
    $encoded = [System.BitConverter]::GetBytes($Value)
    [System.Array]::Copy($encoded, 0, $Bytes, $Offset, 4)
}

function Write-F32([byte[]]$Bytes, [int]$Offset, [single]$Value) {
    $encoded = [System.BitConverter]::GetBytes($Value)
    [System.Array]::Copy($encoded, 0, $Bytes, $Offset, 4)
}

function Find-Tag([byte[]]$Bytes, [string]$Tag) {
    $needle = [System.Text.Encoding]::ASCII.GetBytes($Tag)
    $hits = [System.Collections.Generic.List[int]]::new()
    for ($offset = 0; $offset -le $Bytes.Length - $needle.Length; $offset++) {
        if ($Bytes[$offset] -ne $needle[0]) { continue }
        $matches = $true
        for ($i = 1; $i -lt $needle.Length; $i++) {
            if ($Bytes[$offset + $i] -ne $needle[$i]) {
                $matches = $false
                break
            }
        }
        if ($matches) {
            $hits.Add($offset)
            $offset += $needle.Length - 1
        }
    }
    return $hits.ToArray()
}

function Read-EbpTable([byte[]]$Bytes) {
    $offsets = Find-Tag $Bytes 'DATAEBPT'
    if ($offsets.Count -ne 1) { throw "Expected one DATAEBPT chunk, got $($offsets.Count)" }
    $chunkOffset = $offsets[0]
    $payloadOffset = $chunkOffset + 28
    $count = Read-U32 $Bytes $payloadOffset
    $cursor = $payloadOffset + 4
    $names = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $count; $i++) {
        $length = Read-U32 $Bytes $cursor
        $cursor += 4
        $names.Add([System.Text.Encoding]::ASCII.GetString($Bytes, $cursor, $length).TrimEnd([char]0))
        $cursor += $length
    }
    [pscustomobject]@{
        ChunkOffset = $chunkOffset
        PayloadOffset = $payloadOffset
        PayloadSize = Read-U32 $Bytes ($chunkOffset + 12)
        Names = $names.ToArray()
    }
}

function Get-FoldRanges([byte[]]$Bytes) {
    $ranges = [System.Collections.Generic.List[object]]::new()
    for ($offset = 0; $offset -le $Bytes.Length - 28; $offset++) {
        if ($Bytes[$offset] -ne 0x46) { continue }
        if ([System.Text.Encoding]::ASCII.GetString($Bytes, $offset, 4) -ne 'FOLD') { continue }
        $size = [int64](Read-U32 $Bytes ($offset + 12))
        $nameLength = [int64](Read-U32 $Bytes ($offset + 24))
        $contentStart = [int64]$offset + 28 + $nameLength
        $end = $contentStart + $size
        if ($nameLength -gt 4096 -or $end -gt $Bytes.Length) { continue }
        $ranges.Add([pscustomobject]@{
            Offset = $offset
            ContentStart = $contentStart
            End = $end
            Size = $size
        })
    }
    return $ranges.ToArray()
}

function Update-EnclosingFoldSizes([byte[]]$Bytes, [int64]$Target, [int]$Delta) {
    foreach ($fold in (Get-FoldRanges $Bytes)) {
        if ($Target -ge $fold.ContentStart -and $Target -lt $fold.End) {
            $newSize = [int64]$fold.Size + $Delta
            if ($newSize -lt 0 -or $newSize -gt [uint32]::MaxValue) {
                throw "Invalid fold size after delta at 0x$('{0:X}' -f $fold.Offset)"
            }
            Write-U32 $Bytes ($fold.Offset + 12) ([uint32]$newSize)
        }
    }
}

function Replace-Range([byte[]]$Bytes, [int]$Offset, [int]$OldLength, [byte[]]$Replacement) {
    $result = [byte[]]::new($Bytes.Length - $OldLength + $Replacement.Length)
    [System.Array]::Copy($Bytes, 0, $result, 0, $Offset)
    [System.Array]::Copy($Replacement, 0, $result, $Offset, $Replacement.Length)
    $tailSource = $Offset + $OldLength
    $tailLength = $Bytes.Length - $tailSource
    [System.Array]::Copy($Bytes, $tailSource, $result, $Offset + $Replacement.Length, $tailLength)
    return $result
}

function Get-EntityChunks([byte[]]$Bytes, [string[]]$EbpNames) {
    $chunks = [System.Collections.Generic.List[object]]::new()
    foreach ($foldOffset in (Find-Tag $Bytes 'FOLDENTY')) {
        $nameLength = Read-U32 $Bytes ($foldOffset + 24)
        if ($nameLength -ne 0) { continue }
        $size = Read-U32 $Bytes ($foldOffset + 12)
        $innerOffset = $foldOffset + 28
        if ($innerOffset + 84 -gt $Bytes.Length) { continue }
        if ([System.Text.Encoding]::ASCII.GetString($Bytes, $innerOffset, 8) -ne 'DATAENTI') { continue }
        $id = Read-U32 $Bytes ($innerOffset + 28)
        $typeIndex = Read-U32 $Bytes ($innerOffset + 32)
        $typeName = if ($typeIndex -lt $EbpNames.Count) { $EbpNames[$typeIndex] } else { "<invalid:$typeIndex>" }
        $chunks.Add([pscustomobject]@{
            Offset = $foldOffset
            Length = 28 + [int]$size
            Id = $id
            TypeIndex = $typeIndex
            TypeName = $typeName
        })
    }
    return $chunks.ToArray()
}

function Set-EbpTable([byte[]]$Bytes, [string[]]$Names) {
    $table = Read-EbpTable $Bytes
    $stream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.BinaryWriter]::new($stream)
    $writer.Write([uint32]$Names.Count)
    foreach ($name in $Names) {
        $encoded = [System.Text.Encoding]::ASCII.GetBytes("$name`0")
        $writer.Write([uint32]$encoded.Length)
        $writer.Write($encoded)
    }
    $writer.Flush()
    $payload = $stream.ToArray()
    $writer.Dispose()
    $stream.Dispose()
    $delta = $payload.Length - [int]$table.PayloadSize
    Update-EnclosingFoldSizes $Bytes $table.ChunkOffset $delta
    Write-U32 $Bytes ($table.ChunkOffset + 12) ([uint32]$payload.Length)
    return Replace-Range $Bytes $table.PayloadOffset ([int]$table.PayloadSize) $payload
}

foreach ($path in @($BaseSgb, $TemplateSgb, $LayoutJson)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required file not found: $path" }
}

$bytes = [System.IO.File]::ReadAllBytes($BaseSgb)
$templateBytes = [System.IO.File]::ReadAllBytes($TemplateSgb)
$layout = Get-Content -LiteralPath $LayoutJson -Raw | ConvertFrom-Json

if ([System.Text.Encoding]::ASCII.GetString($bytes, 0, 12) -ne 'Relic Chunky') { throw 'Base file is not Relic Chunky' }
if ([System.Text.Encoding]::ASCII.GetString($templateBytes, 0, 12) -ne 'Relic Chunky') { throw 'Template file is not Relic Chunky' }

$baseTable = Read-EbpTable $bytes
$templateTable = Read-EbpTable $templateBytes

# Remove placeholder cubes and parachute fuel visuals from the rebuild base in one structural edit.
$entityListOffsets = Find-Tag $bytes 'FOLDENTL'
$entityListOffsetBeforeRemoval = $entityListOffsets |
    Where-Object { (Read-U32 $bytes ($_ + 12)) -gt 0 } |
    Select-Object -First 1
if ($null -eq $entityListOffsetBeforeRemoval) { throw 'No non-empty FOLDENTL found' }
$placeholderChunks = Get-EntityChunks $bytes $baseTable.Names |
    Where-Object { $_.TypeName -in @('block_cube_l_01', 'parachute_fuel') } |
    Sort-Object Offset -Descending
$removedLength = [int](($placeholderChunks | Measure-Object Length -Sum).Sum)
if ($removedLength -gt 0) {
    Update-EnclosingFoldSizes $bytes $entityListOffsetBeforeRemoval (-$removedLength)
    Write-U32 $bytes ($entityListOffsetBeforeRemoval + 12) ([uint32]((Read-U32 $bytes ($entityListOffsetBeforeRemoval + 12)) - $removedLength))
    foreach ($remove in $placeholderChunks) {
        $bytes = Replace-Range $bytes $remove.Offset $remove.Length ([byte[]]::new(0))
    }
}

# Preserve the two World Builder-created fuel point templates and move them to the approved layout coordinates.
$fuelChunks = Get-EntityChunks $bytes $baseTable.Names | Where-Object TypeName -eq 'territory_fuel_point_mp' | Sort-Object Id
if ($fuelChunks.Count -ne 2) { throw "Expected 2 fuel points in rebuild base, got $($fuelChunks.Count)" }
for ($i = 0; $i -lt 2; $i++) {
    $fuel = $fuelChunks[$i]
    Write-F32 $bytes ($fuel.Offset + 100) ([single]$layout.fuelPoints[$i].x)
    Write-F32 $bytes ($fuel.Offset + 104) ([single]10)
    Write-F32 $bytes ($fuel.Offset + 108) ([single]$layout.fuelPoints[$i].z)
}

$requiredTypes = @('victory_point', 'territory_point_mp', 'territory_munitions_point_mp')
$allNames = [System.Collections.Generic.List[string]]::new()
foreach ($name in $baseTable.Names) { $allNames.Add($name) }
foreach ($name in $requiredTypes) {
    if (-not $allNames.Contains($name)) { $allNames.Add($name) }
}

$templateChunks = Get-EntityChunks $templateBytes $templateTable.Names
$templates = @{}
foreach ($typeName in $requiredTypes) {
    $template = $templateChunks | Where-Object TypeName -eq $typeName | Select-Object -First 1
    if ($null -eq $template) { throw "No entity template found for $typeName" }
    $chunkBytes = [byte[]]::new($template.Length)
    [System.Array]::Copy($templateBytes, $template.Offset, $chunkBytes, 0, $template.Length)
    $templates[$typeName] = $chunkBytes
}

$bytes = Set-EbpTable $bytes $allNames.ToArray()
$baseTable = Read-EbpTable $bytes

$existingEntities = Get-EntityChunks $bytes $baseTable.Names
$nextId = [uint32](($existingEntities | Measure-Object Id -Maximum).Maximum + 1)
$newChunks = [System.Collections.Generic.List[byte]]::new()

function Add-EntityFromTemplate([string]$TypeName, [single]$X, [single]$Z) {
    $chunk = [byte[]]::new($templates[$TypeName].Length)
    [System.Array]::Copy($templates[$TypeName], 0, $chunk, 0, $chunk.Length)
    $typeIndex = [uint32][System.Array]::IndexOf($baseTable.Names, $TypeName)
    Write-U32 $chunk 56 $script:nextId
    Write-U32 $chunk 60 $typeIndex
    Write-F32 $chunk 100 $X
    Write-F32 $chunk 104 ([single]10)
    Write-F32 $chunk 108 $Z
    $script:nextId++
    $newChunks.AddRange($chunk)
}

foreach ($point in $layout.victoryPoints) { Add-EntityFromTemplate 'victory_point' ([single]$point.x) ([single]$point.z) }
foreach ($point in $layout.territoryPoints) { Add-EntityFromTemplate 'territory_point_mp' ([single]$point.x) ([single]$point.z) }
foreach ($point in $layout.munitionPoints) { Add-EntityFromTemplate 'territory_munitions_point_mp' ([single]$point.x) ([single]$point.z) }

$entityLists = Find-Tag $bytes 'FOLDENTL'
$entityListOffset = $entityLists |
    Where-Object { (Read-U32 $bytes ($_ + 12)) -gt 0 } |
    Select-Object -First 1
if ($null -eq $entityListOffset) { throw 'No non-empty FOLDENTL found for insertion' }
$entityListNameLength = Read-U32 $bytes ($entityListOffset + 24)
$entityListEnd = $entityListOffset + 28 + $entityListNameLength + (Read-U32 $bytes ($entityListOffset + 12))
$insert = $newChunks.ToArray()
Update-EnclosingFoldSizes $bytes $entityListOffset $insert.Length
Write-U32 $bytes ($entityListOffset + 12) ([uint32]((Read-U32 $bytes ($entityListOffset + 12)) + $insert.Length))
$bytes = Replace-Range $bytes $entityListEnd 0 $insert

# Final structural checks.
$finalTable = Read-EbpTable $bytes
$finalEntities = Get-EntityChunks $bytes $finalTable.Names
$counts = $finalEntities | Group-Object TypeName | ForEach-Object { @{$_.Name = $_.Count} }
foreach ($expected in @(
    @{ Type = 'territory_fuel_point_mp'; Count = 2 },
    @{ Type = 'victory_point'; Count = 3 },
    @{ Type = 'territory_point_mp'; Count = 10 },
    @{ Type = 'territory_munitions_point_mp'; Count = 2 }
)) {
    $actual = ($finalEntities | Where-Object TypeName -eq $expected.Type).Count
    if ($actual -ne $expected.Count) { throw "Final count mismatch for $($expected.Type): $actual" }
}
if (($finalEntities | Where-Object TypeName -in @('block_cube_l_01', 'parachute_fuel')).Count -ne 0) {
    throw 'Placeholder entities remain after rebuild'
}

[System.IO.File]::WriteAllBytes($OutputSgb, $bytes)

$finalEntities |
    Where-Object TypeName -match 'victory_point|territory_.*point' |
    Sort-Object TypeName, Id |
    Select-Object Id, TypeName, @{n='X';e={[System.BitConverter]::ToSingle($bytes, $_.Offset + 100)}}, @{n='Y';e={[System.BitConverter]::ToSingle($bytes, $_.Offset + 104)}}, @{n='Z';e={[System.BitConverter]::ToSingle($bytes, $_.Offset + 108)}}
