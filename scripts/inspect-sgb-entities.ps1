param(
    [Parameter(Mandatory = $true)] [string]$SgbPath,
    [string]$NamePattern = '.*'
)

$ErrorActionPreference = 'Stop'

function Read-U32([byte[]]$Bytes, [int]$Offset) {
    [System.BitConverter]::ToUInt32($Bytes, $Offset)
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

$bytes = [System.IO.File]::ReadAllBytes($SgbPath)
$names = Read-EbpNames $bytes

foreach ($foldOffset in (Find-Tag $bytes 'FOLDENTY')) {
    if ((Read-U32 $bytes ($foldOffset + 24)) -ne 0) { continue }
    $dataOffset = $foldOffset + 28
    if ($dataOffset + 84 -gt $bytes.Length) { continue }
    if ([System.Text.Encoding]::ASCII.GetString($bytes, $dataOffset, 8) -ne 'DATAENTI') { continue }
    $typeIndex = Read-U32 $bytes ($dataOffset + 32)
    $typeName = if ($typeIndex -lt $names.Count) { $names[$typeIndex] } else { "<invalid:$typeIndex>" }
    if ($typeName -notmatch $NamePattern) { continue }
    [pscustomobject]@{
        Id = Read-U32 $bytes ($dataOffset + 28)
        Type = $typeName
        X = [math]::Round([System.BitConverter]::ToSingle($bytes, $dataOffset + 72), 2)
        Y = [math]::Round([System.BitConverter]::ToSingle($bytes, $dataOffset + 76), 2)
        Z = [math]::Round([System.BitConverter]::ToSingle($bytes, $dataOffset + 80), 2)
        ChunkOffset = $foldOffset
        ChunkLength = 28 + [int](Read-U32 $bytes ($foldOffset + 12))
    }
}
