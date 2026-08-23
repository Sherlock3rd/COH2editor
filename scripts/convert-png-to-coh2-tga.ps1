param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [int]$Width = 768,
    [int]$Height = 768
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$source = [System.Drawing.Image]::FromFile($InputPath)
$bitmap = [System.Drawing.Bitmap]::new($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.DrawImage($source, 0, 0, $Width, $Height)
$graphics.Dispose()
$source.Dispose()

$rect = [System.Drawing.Rectangle]::new(0, 0, $Width, $Height)
$data = $bitmap.LockBits(
    $rect,
    [System.Drawing.Imaging.ImageLockMode]::ReadOnly,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
)

try {
    $pixels = [byte[]]::new($Width * $Height * 4)
    for ($y = 0; $y -lt $Height; $y++) {
        $row = [IntPtr]::Add($data.Scan0, $y * $data.Stride)
        [Runtime.InteropServices.Marshal]::Copy($row, $pixels, $y * $Width * 4, $Width * 4)
    }

    # COH2's custom-map browser expects an opaque BGRA minimap. Transparent
    # pixels can cause the scenario archive to be skipped instead of merely
    # rendering a transparent preview.
    for ($i = 3; $i -lt $pixels.Length; $i += 4) {
        $pixels[$i] = 255
    }
}
finally {
    $bitmap.UnlockBits($data)
    $bitmap.Dispose()
}

$header = [byte[]]::new(18)
$header[2] = 2
$header[12] = $Width -band 0xff
$header[13] = ($Width -shr 8) -band 0xff
$header[14] = $Height -band 0xff
$header[15] = ($Height -shr 8) -band 0xff
$header[16] = 32
$header[17] = 0x28

$output = [byte[]]::new($header.Length + $pixels.Length)
[Array]::Copy($header, 0, $output, 0, $header.Length)
[Array]::Copy($pixels, 0, $output, $header.Length, $pixels.Length)
[IO.File]::WriteAllBytes($OutputPath, $output)

[pscustomobject]@{
    Path = $OutputPath
    Width = $Width
    Height = $Height
    Bytes = $output.Length
}
