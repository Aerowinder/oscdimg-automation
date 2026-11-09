param (
    [Parameter(Mandatory = $true)][string]$FilePath,
    [Parameter(Mandatory = $true)][string]$ISOPath,
    [string]$OSCDIMGPath = "$PSScriptRoot\bin\oscdimg.exe"
)

# Resolve paths against the current directory
$ResolvedSource = Convert-Path -LiteralPath $FilePath -ErrorAction SilentlyContinue
if (-not $ResolvedSource) { Write-Host "Source folder not found, exiting." -ForegroundColor Red; exit 1 }
$FilePath = $ResolvedSource

$ISOParent = Split-Path -Path $ISOPath -Parent
if (-not $ISOParent) { $ISOParent = '.' }
$ResolvedISOParent = Convert-Path -LiteralPath $ISOParent -ErrorAction SilentlyContinue
if (-not $ResolvedISOParent) { Write-Host "ISO output folder not found: $ISOParent" -ForegroundColor Red; exit 1 }
$ISOPath = Join-Path $ResolvedISOParent (Split-Path -Path $ISOPath -Leaf)

# Validate inputs
if (Test-Path $ISOPath) { Write-Host "ISO file already exists, exiting." -ForegroundColor Red; exit 1 }
if (-not (Test-Path $OSCDIMGPath)) { Write-Host "OSCDIMG not found at $OSCDIMGPath, exiting." -ForegroundColor Red; exit 1 }

# Define boot file paths
$EtfsBoot = Join-Path $FilePath "boot\etfsboot.com"
$EfiBoot  = Join-Path $FilePath "efi\microsoft\boot\efisys.bin"

# Validate boot files
if (-not (Test-Path $EtfsBoot)) { Write-Host "Missing BIOS boot file: $EtfsBoot" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $EfiBoot)) { Write-Host "Missing UEFI boot file: $EfiBoot" -ForegroundColor Red; exit 1 }

# Format arguments
$oscdimgArgs = @(
    "-m"
    "-o"
    "-u2"
    "-udfver102"
    "-bootdata:2#p0,e,b`"$EtfsBoot`"#pEF,e,b`"$EfiBoot`""
    "`"$($FilePath -replace '\\$','\\')`""
    "`"$ISOPath`""
) -join ' '

# Run oscdimg
Write-Host ""
Write-Host "Running oscdimg.exe..."
$process = Start-Process -FilePath $OSCDIMGPath -ArgumentList $oscdimgArgs -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0) {
    Write-Host "ISO built successfully: $ISOPath"
    Write-Host ""
} else {
    Write-Error "oscdimg failed with exit code $($process.ExitCode)"
    Write-Host ""
}

exit $process.ExitCode

# Changelog
# 2025-05-10 - AS - v1, Initial release.
# 2026-11-09 - AS - v2, Bug fixes, fixed some edge cases that would cause builds to fail.