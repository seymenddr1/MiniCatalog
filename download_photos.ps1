# Mini Catalog: download six real product photos from Unsplash.
# Run once in your Flutter project folder (where pubspec.yaml is).
# No Flutter or Dart code changes are necessary.

$ErrorActionPreference = 'Stop'
$folder = Join-Path $PSScriptRoot 'assets\images'
New-Item -ItemType Directory -Force -Path $folder | Out-Null

$photos = @(
    @{ Name = 'headphones.jpg'; Url = 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=700&q=80&fm=jpg&fit=crop' },
    @{ Name = 'keyboard.jpg';   Url = 'https://images.unsplash.com/photo-1584727151652-d09b17ebf23f?w=700&q=80&fm=jpg&fit=crop' },
    @{ Name = 'tshirt.jpg';     Url = 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=700&q=80&fm=jpg&fit=crop' },
    @{ Name = 'mug.jpg';        Url = 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=700&q=80&fm=jpg&fit=crop' },
    @{ Name = 'lamp.jpg';       Url = 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=700&q=80&fm=jpg&fit=crop' },
    @{ Name = 'notebook.jpg';   Url = 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=700&q=80&fm=jpg&fit=crop' }
)

foreach ($photo in $photos) {
    $destination = Join-Path $folder $photo.Name
    Write-Host "Downloading $($photo.Name)..."
    try {
        Invoke-WebRequest -Uri $photo.Url -OutFile $destination -UseBasicParsing -TimeoutSec 40
        $bytes = [System.IO.File]::ReadAllBytes($destination)
        if ($bytes.Length -lt 4000 -or $bytes[0] -ne 255 -or $bytes[1] -ne 216) {
            throw "File is not a valid JPEG image"
        }
        Write-Host "Saved $($photo.Name) ($($bytes.Length) bytes)" -ForegroundColor Green
    } catch {
        Remove-Item -LiteralPath $destination -ErrorAction SilentlyContinue
        Write-Host "Could not download $($photo.Name): $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "You can manually save the photo as assets/images/$($photo.Name) from: $($photo.Url)" -ForegroundColor Yellow
        exit 1
    }
}
Write-Host 'All six photos downloaded successfully. Now run: flutter pub get; flutter run' -ForegroundColor Green
