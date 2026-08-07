# ==============================================================================
# Module: Utils.ps1
# Description: System checks, registry searches, file paths, byte formatting
# ==============================================================================

function Test-IsAdmin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-AppInstalled {
    param (
        [string]$CheckPath,
        [string]$AppName
    )
    
    # 1. Checagem direta por arquivo executável
    if (-not [string]::IsNullOrWhiteSpace($CheckPath)) {
        $expandedPath = [System.Environment]::ExpandEnvironmentVariables($CheckPath)
        if (Test-Path -Path $expandedPath) {
            return $true
        }
    }

    # 2. Varredura no Registro de Desinstalação do Windows
    if (-not [string]::IsNullOrWhiteSpace($AppName)) {
        $regKeys = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($key in $regKeys) {
            $installed = Get-ItemProperty $key -ErrorAction SilentlyContinue | 
                Where-Object { $_.DisplayName -and $_.DisplayName -like "*$AppName*" }
            if ($installed) {
                return $true
            }
        }
    }

    return $false
}

function Format-Bytes {
    param ([double]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "{0:N0} Bytes" -f $Bytes
}