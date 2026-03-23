function Open-GpuDriverPageIfWanted {
    Write-Host ""
    $openDriverPage = Read-YesNo -Prompt "Do you want to open the GPU driver download page"

    if (-not $openDriverPage) {
        Write-Info "GPU driver page was not opened."
        Write-Host ""
        return
    }

    try {
        $gpus = Get-CimInstance Win32_VideoController -ErrorAction Stop |
            Select-Object -ExpandProperty Name |
            Where-Object { $_ -and $_.Trim() -ne "" }

        if ($gpus) {
            $integratedPatterns = @('Intel.*Graphics', 'AMD.*Radeon.*Graphics', 'Microsoft.*Hyper-V')
            $dedicatedGpus = @()
            $integratedGpus = @()

            foreach ($gpu in $gpus) {
                $isIntegrated = $false
                foreach ($pattern in $integratedPatterns) {
                    if ($gpu -match $pattern) {
                        $isIntegrated = $true
                        $integratedGpus += $gpu
                        break
                    }
                }

                if (-not $isIntegrated) {
                    $dedicatedGpus += $gpu
                }
            }

            $selectedGpu = if ($dedicatedGpus.Count -gt 0) { $dedicatedGpus[0] } else { $gpus[0] }
            $selectedGpuLower = $selectedGpu.ToLowerInvariant()

            if ($selectedGpuLower -match 'nvidia') {
                Write-Info "NVIDIA GPU detected: $selectedGpu"
                Write-Info "Opening NVIDIA driver page..."
                Start-Process "https://www.nvidia.com/en-us/drivers/"
                Write-Ok "NVIDIA driver page opened."
                Write-Host ""
                return
            }
            elseif ($selectedGpuLower -match 'amd') {
                Write-Info "AMD GPU detected: $selectedGpu"
                Write-Info "Opening AMD driver page..."
                Start-Process "https://www.amd.com/en/support/download/drivers.html"
                Write-Ok "AMD driver page opened."
                Write-Host ""
                return
            }
            else {
                Write-WarnMsg "Could not determine GPU vendor from: $selectedGpu"
                Write-Info "Detected GPUs: $($gpus -join ', ')"
                Write-Host ""
            }
        }
        else {
            Write-WarnMsg "No GPUs detected via WMI."
        }
    }
    catch {
        Write-Verbose "Unable to query GPU information via WMI"
    }

    Write-Host ""

    while ($true) {
        $gpuVendor = (Read-Host "Please specify your GPU vendor (NVIDIA/AMD)").Trim().ToLowerInvariant()

        switch ($gpuVendor) {
            'amd' {
                Write-Info "Opening AMD driver page..."
                Start-Process "https://www.amd.com/en/support/download/drivers.html"
                Write-Ok "AMD driver page opened."
                Write-Host ""
                return
            }
            'nvidia' {
                Write-Info "Opening NVIDIA driver page..."
                Start-Process "https://www.nvidia.com/en-us/drivers/"
                Write-Ok "NVIDIA driver page opened."
                Write-Host ""
                return
            }
            default {
                Write-Host "Please enter NVIDIA or AMD."
            }
        }
    }
}

function Open-ChipsetsDriverPageIfWanted {
    Write-Host ""
    $openChipsetsPage = Read-YesNo -Prompt "Do you want to open the chipset driver download page"

    if (-not $openChipsetsPage) {
        Write-Info "Chipset driver page was not opened."
        Write-Host ""
        return
    }

    try {
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop |
            Select-Object -First 1 -ExpandProperty Name
        $cpuLower = $cpu.ToLowerInvariant()

        if ($cpuLower -match 'intel') {
            Write-Info "Intel CPU detected."
            Write-Info "Opening Intel chipset drivers page..."
            Start-Process "https://www.intel.com/content/www/us/en/download-center/home.html"
            Write-Ok "Intel chipset driver page opened."
            Write-Host ""
            return
        }
        elseif ($cpuLower -match 'amd') {
            Write-Info "AMD CPU detected."
            Write-Info "Opening AMD chipset drivers page..."
            Start-Process "https://www.amd.com/en/support/download/drivers.html"
            Write-Ok "AMD chipset driver page opened."
            Write-Host ""
            return
        }
        else {
            Write-WarnMsg "Could not determine CPU manufacturer from: $cpu"
            Write-Host ""
        }
    }
    catch {
        Write-WarnMsg "Unable to determine CPU information. Please select manually."
        Write-Host ""
    }

    while ($true) {
        $cpuVendor = (Read-Host "Please specify your CPU vendor (Intel/AMD)").Trim().ToLowerInvariant()

        switch ($cpuVendor) {
            'intel' {
                Write-Info "Opening Intel chipset drivers page..."
                Start-Process "https://www.intel.com/content/www/us/en/download-center/home.html"
                Write-Ok "Intel chipset driver page opened."
                Write-Host ""
                return
            }
            'amd' {
                Write-Info "Opening AMD chipset drivers page..."
                Start-Process "https://www.amd.com/en/support/download/drivers.html"
                Write-Ok "AMD chipset driver page opened."
                Write-Host ""
                return
            }
            default {
                Write-Host "Please enter Intel or AMD."
            }
        }
    }
}

function Open-NiniteIfWanted {
    Write-Host ""
    $openNinite = Read-YesNo -Prompt "Do you want to open Ninite to install useful apps"

    if ($openNinite) {
        Write-Info "Opening Ninite in your browser..."
        Start-Process "https://ninite.com/"
        Write-Ok "Ninite opened."
    }
    else {
        Write-Info "Ninite was not opened."
    }

    Write-Host ""
}

function Start-WindowsUpdateIfWanted {
    Write-Host ""
    $startUpdate = Read-YesNo -Prompt "Do you want to check for Windows Updates now"

    if ($startUpdate) {
        Write-Info "Triggering Windows Update scan..."

        try {
            Start-Process "UsoClient.exe" -ArgumentList "StartScan"
        }
        catch {
            Write-Verbose "UsoClient scan trigger failed, continuing..."
        }

        Start-Process "ms-settings:windowsupdate"
        Write-Ok "Windows Update scan triggered."
        Write-Info "Check the Windows Update page for progress."
    }
    else {
        Write-Info "Windows Update was not started."
    }

    Write-Host ""
}

function Start-DebloaterIfWanted {
    Write-Host ""
    $startDebloater = Read-YesNo -Prompt "Do you want to start the debloater"

    if ($startDebloater) {
        Write-Info "Starting debloater in a new PowerShell window..."

        $command = '& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))'

        Start-Process powershell.exe -Verb RunAs -ArgumentList @(
            '-NoExit',
            '-ExecutionPolicy', 'Bypass',
            '-Command', $command
        )

        Write-Ok "Debloater started in a new window."
    }
    else {
        Write-Info "Debloater was not started."
    }

    Write-Host ""
}
