param(
    [Parameter(Mandatory = $true)] [string]$SgbPath,
    [Parameter(Mandatory = $true)] [string]$PlacementsJson
)

$ErrorActionPreference = 'Stop'

function Read-U32([byte[]]$Bytes, [int]$Offset) { [System.BitConverter]::ToUInt32($Bytes, $Offset) }
function Write-U32([byte[]]$Bytes, [int]$Offset, [uint32]$Value) {
    [System.Array]::Copy([System.BitConverter]::GetBytes($Value), 0, $Bytes, $Offset, 4)
}
function Write-F32([byte[]]$Bytes, [int]$Offset, [single]$Value) {
    [System.Array]::Copy([System.BitConverter]::GetBytes($Value), 0, $Bytes, $Offset, 4)
}
function Find-Tag([byte[]]$Bytes, [string]$Tag) {
    $needle = [System.Text.Encoding]::ASCII.GetBytes($Tag)
    $hits = [System.Collections.Generic.List[int]]::new()
    for ($offset = 0; $offset -le $Bytes.Length - $needle.Length; $offset++) {
        if ($Bytes[$offset] -ne $needle[0]) { continue }
        $matches = $true
        for ($i = 1; $i -lt $needle.Length; $i++) {
            if ($Bytes[$offset + $i] -ne $needle[$i]) { $matches = $false; break }
        }
        if ($matches) { $hits.Add($offset); $offset += $needle.Length - 1 }
    }
    $hits.ToArray()
}
function Read-EbpNames([byte[]]$Bytes) {
    $tag = @(Find-Tag $Bytes 'DATAEBPT')
    if ($tag.Count -ne 1) { throw "Expected one DATAEBPT chunk, got $($tag.Count)" }
    $cursor = $tag[0] + 28
    $count = Read-U32 $Bytes $cursor
    $cursor += 4
    $names = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $count; $i++) {
        $length = Read-U32 $Bytes $cursor
        $cursor += 4
        $names.Add([System.Text.Encoding]::ASCII.GetString($Bytes, $cursor, $length).TrimEnd([char]0))
        $cursor += $length
    }
    $names.ToArray()
}
function Get-EntityChunks([byte[]]$Bytes, [string[]]$Names) {
    foreach ($foldOffset in (Find-Tag $Bytes 'FOLDENTY')) {
        if ((Read-U32 $Bytes ($foldOffset + 24)) -ne 0) { continue }
        $dataOffset = $foldOffset + 28
        if ($dataOffset + 84 -gt $Bytes.Length) { continue }
        if ([System.Text.Encoding]::ASCII.GetString($Bytes, $dataOffset, 8) -ne 'DATAENTI') { continue }
        $typeIndex = Read-U32 $Bytes ($dataOffset + 32)
        [pscustomobject]@{
            Offset = $foldOffset
            Length = 28 + [int](Read-U32 $Bytes ($foldOffset + 12))
            Id = Read-U32 $Bytes ($dataOffset + 28)
            Type = if ($typeIndex -lt $Names.Count) { $Names[$typeIndex] } else { "<invalid:$typeIndex>" }
        }
    }
}
function Get-FoldRanges([byte[]]$Bytes) {
    foreach ($offset in (Find-Tag $Bytes 'FOLD')) {
        if ($offset + 28 -gt $Bytes.Length) { continue }
        $size = [int64](Read-U32 $Bytes ($offset + 12))
        $nameLength = [int64](Read-U32 $Bytes ($offset + 24))
        $contentStart = [int64]$offset + 28 + $nameLength
        $end = $contentStart + $size
        if ($nameLength -le 4096 -and $end -le $Bytes.Length) {
            [pscustomobject]@{ Offset = $offset; ContentStart = $contentStart; End = $end; Size = $size }
        }
    }
}
function Update-EnclosingFoldSizes([byte[]]$Bytes, [int64]$Target, [int]$Delta) {
    foreach ($fold in (Get-FoldRanges $Bytes)) {
        if ($Target -ge $fold.ContentStart -and $Target -lt $fold.End) {
            Write-U32 $Bytes ($fold.Offset + 12) ([uint32]($fold.Size + $Delta))
        }
    }
}
function Insert-Bytes([byte[]]$Bytes, [int]$Offset, [byte[]]$Insert) {
    $result = [byte[]]::new($Bytes.Length + $Insert.Length)
    [System.Array]::Copy($Bytes, 0, $result, 0, $Offset)
    [System.Array]::Copy($Insert, 0, $result, $Offset, $Insert.Length)
    [System.Array]::Copy($Bytes, $Offset, $result, $Offset + $Insert.Length, $Bytes.Length - $Offset)
    $result
}

$bytes = [System.IO.File]::ReadAllBytes($SgbPath)
$placements = @(Get-Content -LiteralPath $PlacementsJson -Raw | ConvertFrom-Json)
if ($placements.Count -eq 0) { throw 'No placements supplied' }
$names = Read-EbpNames $bytes
$entities = @(Get-EntityChunks $bytes $names)
$templates = @{}
foreach ($type in ($placements.type | Sort-Object -Unique)) {
    $source = $entities | Where-Object Type -eq $type | Select-Object -First 1
    if ($null -eq $source) { throw "No existing entity template for type: $type" }
    $chunk = [byte[]]::new($source.Length)
    [System.Array]::Copy($bytes, $source.Offset, $chunk, 0, $source.Length)
    $templates[$type] = $chunk
}

$nextId = [uint32](($entities | Measure-Object Id -Maximum).Maximum + 1)
$newBytes = [System.Collections.Generic.List[byte]]::new()
foreach ($placement in $placements) {
    $chunk = [byte[]]::new($templates[$placement.type].Length)
    [System.Array]::Copy($templates[$placement.type], 0, $chunk, 0, $chunk.Length)
    Write-U32 $chunk 56 $nextId
    Write-F32 $chunk 100 ([single]$placement.x)
    Write-F32 $chunk 104 ([single]$placement.y)
    Write-F32 $chunk 108 ([single]$placement.z)
    $newBytes.AddRange($chunk)
    $nextId++
}

$entityListOffset = Find-Tag $bytes 'FOLDENTL' |
    Where-Object { (Read-U32 $bytes ($_ + 12)) -gt 0 } |
    Select-Object -First 1
if ($null -eq $entityListOffset) { throw 'No non-empty FOLDENTL found' }
$nameLength = Read-U32 $bytes ($entityListOffset + 24)
$insertOffset = $entityListOffset + 28 + $nameLength + (Read-U32 $bytes ($entityListOffset + 12))
$insert = $newBytes.ToArray()
Update-EnclosingFoldSizes $bytes $entityListOffset $insert.Length
Write-U32 $bytes ($entityListOffset + 12) ([uint32]((Read-U32 $bytes ($entityListOffset + 12)) + $insert.Length))
$bytes = Insert-Bytes $bytes $insertOffset $insert

$tempPath = "$SgbPath.codex-clone.tmp"
[System.IO.File]::WriteAllBytes($tempPath, $bytes)
$verifyNames = Read-EbpNames $bytes
$verifyEntities = @(Get-EntityChunks $bytes $verifyNames)
if ($verifyEntities.Count -ne $entities.Count + $placements.Count) {
    throw "Entity count mismatch after clone: $($verifyEntities.Count)"
}
Move-Item -LiteralPath $tempPath -Destination $SgbPath -Force

[pscustomobject]@{
    Added = $placements.Count
    Before = $entities.Count
    After = $verifyEntities.Count
    FirstNewId = [uint32](($entities | Measure-Object Id -Maximum).Maximum + 1)
    LastNewId = $nextId - 1
}
