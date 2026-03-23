param()

$scriptsDir  = Join-Path (Split-Path -Parent $PSScriptRoot) 'scripts'
$modulesDir  = Join-Path $scriptsDir 'modules'

Describe "setup.ps1 Validation" {

    BeforeAll {
        $SetupScriptPath = Join-Path $scriptsDir 'setup.ps1'
    }

    It "Script exists" {
        Test-Path -Path $SetupScriptPath | Should -Be $true
    }

    It "Script has valid PowerShell syntax" {
        $errors = @()
        $null = [System.Management.Automation.PSParser]::Tokenize(
            (Get-Content -Path $SetupScriptPath -Raw),
            [ref]$errors
        )
        $errors.Count | Should -Be 0
    }

    It "Script can be parsed without execution" {
        {
            [void]([System.Management.Automation.PSParser]::Tokenize(
                (Get-Content -Path $SetupScriptPath -Raw),
                [ref]@()
            ))
        } | Should -Not -Throw
    }
}

Describe "Module Syntax Validation" {

    $moduleFiles = @('helpers.ps1', 'system.ps1', 'tweaks.ps1', 'apps.ps1')

    foreach ($file in $moduleFiles) {
        It "modules\$file has valid PowerShell syntax" {
            $path = Join-Path $modulesDir $file
            Test-Path $path | Should -Be $true
            $errors = @()
            $null = [System.Management.Automation.PSParser]::Tokenize(
                (Get-Content -Path $path -Raw),
                [ref]$errors
            )
            $errors.Count | Should -Be 0
        }
    }
}

Describe "Script Structure" {

    BeforeAll {
        $script:allContent = (Get-ChildItem -Path $modulesDir -Filter '*.ps1') |
            ForEach-Object { Get-Content $_.FullName -Raw } |
            Out-String
    }

    It "Contains function Test-IsAdmin" {
        $script:allContent | Should -Match 'function\s+Test-IsAdmin'
    }

    It "Contains function Wait-A-Bit" {
        $script:allContent | Should -Match 'function\s+Wait-A-Bit'
    }

    It "Contains function Read-YesNo" {
        $script:allContent | Should -Match 'function\s+Read-YesNo'
    }

    It "Contains function Write-Info" {
        $script:allContent | Should -Match 'function\s+Write-Info'
    }

    It "Contains function Write-Ok" {
        $script:allContent | Should -Match 'function\s+Write-Ok'
    }

    It "Contains function Set-DwordValue" {
        $script:allContent | Should -Match 'function\s+Set-DwordValue'
    }

    It "Contains function Set-StringValue" {
        $script:allContent | Should -Match 'function\s+Set-StringValue'
    }

    It "Contains Set-BiosRecommendationsFileIfWanted function" {
        $script:allContent | Should -Match 'function\s+Set-BiosRecommendationsFileIfWanted'
    }

    It "Contains Set-OptionalDiagnosticDataOff function" {
        $script:allContent | Should -Match 'function\s+Set-OptionalDiagnosticDataOff'
    }

    It "Contains Set-DeliveryOptimizationHttpOnly function" {
        $script:allContent | Should -Match 'function\s+Set-DeliveryOptimizationHttpOnly'
    }

    It "Contains Set-HardwareAcceleratedGpuSchedulingOn function" {
        $script:allContent | Should -Match 'function\s+Set-HardwareAcceleratedGpuSchedulingOn'
    }

    It "Contains Set-VariableRefreshRateOn function" {
        $script:allContent | Should -Match 'function\s+Set-VariableRefreshRateOn'
    }

    It "Contains Set-GameModeOff function" {
        $script:allContent | Should -Match 'function\s+Set-GameModeOff'
    }

    It "Contains Set-MouseAccelerationOff function" {
        $script:allContent | Should -Match 'function\s+Set-MouseAccelerationOff'
    }

    It "Contains Show-SystemInformation function" {
        $script:allContent | Should -Match 'function\s+Show-SystemInformation'
    }

    It "Contains Open-GpuDriverPageIfWanted function" {
        $script:allContent | Should -Match 'function\s+Open-GpuDriverPageIfWanted'
    }

    It "Contains Open-ChipsetsDriverPageIfWanted function" {
        $script:allContent | Should -Match 'function\s+Open-ChipsetsDriverPageIfWanted'
    }

    It "Uses Read-YesNo for user confirmations" {
        $script:allContent | Should -Match 'Read-YesNo'
    }

    It "Uses Write-Verbose for debugging" {
        $script:allContent | Should -Match 'Write-Verbose'
    }
}

Describe "setup.ps1 Orchestration" {

    BeforeAll {
        $script:setupContent = Get-Content (Join-Path $scriptsDir 'setup.ps1') -Raw
    }

    It "Dot-sources all modules" {
        $script:setupContent | Should -Match '\.\s+".*helpers\.ps1"'
        $script:setupContent | Should -Match '\.\s+".*system\.ps1"'
        $script:setupContent | Should -Match '\.\s+".*tweaks\.ps1"'
        $script:setupContent | Should -Match '\.\s+".*apps\.ps1"'
    }

    It "Has proper error handling" {
        $script:setupContent | Should -Match 'catch\s*{'
    }
}
