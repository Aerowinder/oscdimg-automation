param (
    [Parameter(Mandatory = $true)][string]$FilePath,
    [Parameter(Mandatory = $true)][string]$ISOPath,
    [string]$OSCDIMGPath = "$PSScriptRoot\bin\oscdimg.exe"
)

# Normalize paths
if ($FilePath.StartsWith('.\')) { $FilePath = Join-Path $PSScriptRoot $FilePath.Substring(2) }
if ($ISOPath.StartsWith('.\')) { $ISOPath = Join-Path $PSScriptRoot $ISOPath.Substring(2) }

# Validate inputs
if (-not (Test-Path $FilePath)) { Write-Host "Source folder not found, exiting." -ForegroundColor Red; exit }
if (Test-Path $ISOPath) { Write-Host "ISO file already exists, exiting." -ForegroundColor Red; exit }
if (-not (Test-Path $OSCDIMGPath)) { Write-Host "OSCDIMG not found at $OSCDIMGPath, exiting." -ForegroundColor Red; exit }

# Define boot file paths
$EtfsBoot = Join-Path $FilePath "boot\etfsboot.com"
$EfiBoot  = Join-Path $FilePath "efi\microsoft\boot\efisys.bin"

# Validate boot files
if (-not (Test-Path $EtfsBoot)) { Write-Host "Missing BIOS boot file: $EtfsBoot" -ForegroundColor Red; exit }
if (-not (Test-Path $EfiBoot)) { Write-Host "Missing UEFI boot file: $EfiBoot"-ForegroundColor Red; exit }

# Format arguments
$oscdimgArgs = @(
    "-m"
    "-o"
    "-u2"
    "-udfver102"
    "-bootdata:2#p0,e,b$EtfsBoot#pEF,e,b$EfiBoot"
    "`"$FilePath`""
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

#Changelog
#2025-05-10 - AS - v1, Initial release.
