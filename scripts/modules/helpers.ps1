function Test-IsAdmin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Wait-A-Bit {
    $seconds = Get-Random -Minimum 1 -Maximum 3
    Start-Sleep -Seconds $seconds
}

function Restart-AsAdmin {
    if (-not (Test-IsAdmin)) {
        Write-Host ""
        Write-Host "This script requires administrator privileges."
        Wait-A-Bit

        Write-Host "User Account Control will open now..."
        Wait-A-Bit
        Write-Host ""

        $scriptPath = $PSCommandPath

        if (-not $scriptPath) {
            throw "The script path could not be determined. Start the script directly with .\setup.ps1"
        }

        Start-Process powershell.exe `
            -Verb RunAs `
            -ArgumentList @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', "`"$scriptPath`""
        )

        exit
    }
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO ] $Message"
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[ OK  ] $Message"
}

function Write-WarnMsg {
    param([string]$Message)
    Write-Warning $Message
}

function Read-YesNo {
    param(
        [Parameter(Mandatory)]
        [string]$Prompt
    )

    while ($true) {
        $answer = (Read-Host "$Prompt (Yes/No)").Trim().ToLowerInvariant()

        switch ($answer) {
            'y' { return $true }
            'yes' { return $true }
            'n' { return $false }
            'no' { return $false }
            default { Write-Host "Please enter 'Yes' or 'No'." }
        }
    }
}

function Test-RegistryKey {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

function Set-DwordValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][int]$Value
    )

    Test-RegistryKey -Path $Path
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
    Write-Ok "$Path -> $Name = $Value"
}

function Set-StringValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Value
    )

    Test-RegistryKey -Path $Path
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType String -Force | Out-Null
    Write-Ok "$Path -> $Name = $Value"
}
