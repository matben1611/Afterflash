[CmdletBinding()]
param()

$root    = $PSScriptRoot
$batFile = Join-Path $root 'afterflash-standalone.bat'
$pngFile = Join-Path $root 'afterflash.png'
$ps1File = Join-Path $root 'afterflash-standalone.ps1'
$icoFile = Join-Path $root 'afterflash.ico'
$exeFile = Join-Path $root 'afterflash.exe'

# --- 1. Extract PS code from bat ---
Write-Host "[1/4] Extracting PowerShell code from bat..."
$lines = Get-Content $batFile -Encoding UTF8
$startIndex = $null
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^##PSBEGIN##') {
        $startIndex = $i + 1
        break
    }
}
if ($null -eq $startIndex) {
    throw "##PSBEGIN## marker not found in $batFile"
}
$psContent = $lines[$startIndex..($lines.Count - 1)] -join "`r`n"
Set-Content -Path $ps1File -Value $psContent -Encoding UTF8
Write-Host "    -> $ps1File"

# --- 2. Convert PNG to ICO ---
Write-Host "[2/4] Converting PNG to ICO..."
Add-Type -AssemblyName System.Drawing
$bitmap     = [System.Drawing.Bitmap]::new($pngFile)
$iconHandle = $bitmap.GetHicon()
$icon       = [System.Drawing.Icon]::FromHandle($iconHandle)
$stream     = [System.IO.FileStream]::new($icoFile, [System.IO.FileMode]::Create)
$icon.Save($stream)
$stream.Dispose()
$icon.Dispose()
$bitmap.Dispose()
Write-Host "    -> $icoFile"

# --- 3. Install PS2EXE if needed ---
Write-Host "[3/4] Checking PS2EXE..."
if (-not (Get-Module -ListAvailable -Name PS2EXE)) {
    Write-Host "    PS2EXE not found, installing..."
    Install-Module PS2EXE -Scope CurrentUser -Force
}
Import-Module PS2EXE

# --- 4. Compile to EXE ---
Write-Host "[4/4] Compiling to EXE..."
Invoke-PS2EXE `
    -InputFile    $ps1File `
    -OutputFile   $exeFile `
    -iconFile     $icoFile `
    -title        'afterflash' `
    -description  'Windows Setup & Optimizer' `
    -requireAdmin

Write-Host ""
Write-Host "Done: $exeFile"
