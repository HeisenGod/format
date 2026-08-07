# ==============================================================================
# Module: Logger.ps1
# Description: Centralized logging system writing to logs/install.log
# ==============================================================================

function Initialize-Logger {
    param (
        [string]$BaseDirectory = "$PSScriptRoot/.."
    )
    $logDir = Join-Path -Path $BaseDirectory -ChildPath "logs"
    if (-not (Test-Path -Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    $global:LogFilePath = Join-Path -Path $logDir -ChildPath "install.log"
    if (-not (Test-Path -Path $global:LogFilePath)) {
        New-Item -ItemType File -Path $global:LogFilePath -Force | Out-Null
    }
}

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"
    
    if ($global:LogFilePath) {
        Add-Content -Path $global:LogFilePath -Value $logLine -ErrorAction SilentlyContinue
    }
    
    switch ($Level) {
        "ERROR"   { Write-Host $logLine -ForegroundColor Red }
        "WARNING" { Write-Host $logLine -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logLine -ForegroundColor Green }
        Default   { Write-Host $logLine -ForegroundColor Gray }
    }
}