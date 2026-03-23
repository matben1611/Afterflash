function Set-HardwareAcceleratedGpuSchedulingOn {
    Write-Host ""
    $enableGpuScheduling = Read-YesNo -Prompt "Do you want to enable hardware-accelerated GPU scheduling"

    if ($enableGpuScheduling) {
        Write-Info "Enabling hardware-accelerated GPU scheduling..."

        Set-DwordValue `
            -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' `
            -Name 'HwSchMode' `
            -Value 2

        Write-WarnMsg "A restart may be required."
    }
    else {
        Write-Info "Hardware-accelerated GPU scheduling was not changed."
    }

    Write-Host ""
}

function Set-VariableRefreshRateOn {
    Write-Host ""
    $enableVrr = Read-YesNo -Prompt "Do you want to enable Variable Refresh Rate"

    if ($enableVrr) {
        Write-Info "Enabling Variable Refresh Rate..."

        $path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
        $name = 'DirectXUserGlobalSettings'

        Test-RegistryKey -Path $path

        $existing = ''
        try {
            $existing = (Get-ItemProperty -Path $path -Name $name -ErrorAction Stop).$name
        }
        catch {
            $existing = ''
        }

        $map = [ordered]@{}

        if ($existing) {
            $tokens = $existing -split ';' | Where-Object { $_ -and $_.Trim() -ne '' }
            foreach ($token in $tokens) {
                $parts = $token -split '=', 2
                if ($parts.Count -eq 2) {
                    $map[$parts[0].Trim()] = $parts[1].Trim()
                }
            }
        }

        $map['VRROptimizeEnable'] = '1'

        $newValue = (($map.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ';') + ';'

        Set-StringValue -Path $path -Name $name -Value $newValue
        Write-WarnMsg "Signing out/in or restarting may be required."
    }
    else {
        Write-Info "Variable Refresh Rate settings were not changed."
    }

    Write-Host ""
}

function Set-GameModeOff {
    Write-Host ""
    $disableGameMode = Read-YesNo -Prompt "Do you want to disable Game Mode"

    if ($disableGameMode) {
        Write-Info "Disabling Game Mode..."

        Set-DwordValue `
            -Path 'HKCU:\Software\Microsoft\GameBar' `
            -Name 'AutoGameModeEnabled' `
            -Value 0

        Write-Ok "Game Mode disabled."
    }
    else {
        Write-Info "Game Mode settings were not changed."
    }

    Write-Host ""
}

function Set-MouseAccelerationOff {
    Write-Host ""
    $disableMouseAcceleration = Read-YesNo -Prompt "Do you want to disable mouse acceleration"

    if ($disableMouseAcceleration) {
        Write-Info "Disabling mouse acceleration..."

        $path = 'HKCU:\Control Panel\Mouse'
        Test-RegistryKey -Path $path

        Set-StringValue -Path $path -Name 'MouseSpeed'      -Value '0'
        Set-StringValue -Path $path -Name 'MouseThreshold1' -Value '0'
        Set-StringValue -Path $path -Name 'MouseThreshold2' -Value '0'

        Write-WarnMsg "Signing out/in or restarting may be required."
    }
    else {
        Write-Info "Mouse acceleration settings were not changed."
    }

    Write-Host ""
}

function Set-PowerPlan {
    Write-Host ""
    $setPowerPlan = Read-YesNo -Prompt "Do you want to set the optimal power plan for your CPU"

    if (-not $setPowerPlan) {
        Write-Info "Power plan was not changed."
        Write-Host ""
        return
    }

    $cpu = "Unknown"
    try {
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop |
            Select-Object -First 1 -ExpandProperty Name
    }
    catch {
        Write-Verbose "Unable to retrieve CPU information"
    }

    $cpuLower = $cpu.ToLowerInvariant()

    if ($cpuLower -match 'x3d') {
        Write-Info "X3D CPU detected: $cpu"
        Write-Info "Setting power plan to Balanced (recommended for X3D)..."
        powercfg /setactive SCHEME_BALANCED | Out-Null
        Write-Ok "Power plan set to Balanced."
    }
    else {
        Write-Info "CPU detected: $cpu"

        $ultimateGuid = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
        $schemes = powercfg /list 2>&1

        if ($schemes -match $ultimateGuid) {
            Write-Info "Setting power plan to Ultimate Performance..."
            powercfg /setactive $ultimateGuid | Out-Null
            Write-Ok "Power plan set to Ultimate Performance."
        }
        else {
            Write-Info "Ultimate Performance not available."
            Write-Info "Setting power plan to High Performance..."
            powercfg /setactive SCHEME_MIN | Out-Null
            Write-Ok "Power plan set to High Performance."
        }
    }

    Write-Host ""
}

function Set-OptionalDiagnosticDataOff {
    Write-Host ""
    $disableDiagnostics = Read-YesNo -Prompt "Do you want to disable optional diagnostic data"

    if ($disableDiagnostics) {
        Write-Info "Disabling optional diagnostic data..."

        Set-DwordValue `
            -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
            -Name 'AllowTelemetry' `
            -Value 1

        Write-Ok "Diagnostic data set to Required only."
    }
    else {
        Write-Info "Diagnostic data settings were not changed."
    }

    Write-Host ""
}

function Set-DeliveryOptimizationHttpOnly {
    Write-Host ""
    $disableDeliveryOptimization = Read-YesNo -Prompt "Do you want to disable Delivery Optimization peer-to-peer"

    if ($disableDeliveryOptimization) {
        Write-Info "Setting Delivery Optimization to HTTP only..."

        Set-DwordValue `
            -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' `
            -Name 'DODownloadMode' `
            -Value 0

        Write-Ok "Delivery Optimization peer-to-peer disabled."
    }
    else {
        Write-Info "Delivery Optimization settings were not changed."
    }

    Write-Host ""
}

function Set-SystemProtectionIfWanted {
    Write-Host ""
    $enableSystemProtection = Read-YesNo -Prompt "Do you want to enable System Protection on drive C"

    if ($enableSystemProtection) {
        Write-Info "Enabling System Protection on C: ..."
        Enable-ComputerRestore -Drive "C:\"
        Write-Ok "System Protection enabled on C:."
    }
    else {
        Write-Info "System Protection was not changed."
    }

    Write-Host ""
}

function Set-ClipboardHistoryIfWanted {
    Write-Host ""
    $enableClipboardHistory = Read-YesNo -Prompt "Do you want to enable Clipboard History"

    if ($enableClipboardHistory) {
        Write-Info "Enabling Clipboard History..."

        Set-DwordValue `
            -Path 'HKCU:\Software\Microsoft\Clipboard' `
            -Name 'EnableClipboardHistory' `
            -Value 1

        Write-Ok "Clipboard History enabled."

        $openClipboardSettings = Read-YesNo -Prompt "Do you want to open Clipboard settings now"

        if ($openClipboardSettings) {
            Start-Process "ms-settings:clipboard"
            Write-Info "Clipboard settings opened."
        }
    }
    else {
        Write-Info "Clipboard History was not changed."
    }

    Write-Host ""
}

function Test-DoNotDisturbIfWanted {
    Write-Host ""
    $configureDnd = Read-YesNo -Prompt "Do you want to configure Do Not Disturb now"

    if ($configureDnd) {
        Write-Info "Opening Notifications settings..."
        Start-Process "ms-settings:notifications"
        Write-Info "Set Do Not Disturb manually in the Notifications page."
    }
    else {
        Write-Info "Do Not Disturb was not changed."
    }

    Write-Host ""
}
