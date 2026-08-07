# ==============================================================================
# Project: Windows Format Installer
# Author: HeisenGod
# Description: Automated Windows post-format software & configuration installer
# ==============================================================================

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# 1. Elevação Automática para Administrador
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requisitando permissões de Administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. Bootstrap para Execução Web / One-Liner (irm ... | iex)
$ScriptPath = $PSScriptRoot
if ([string]::IsNullOrEmpty($ScriptPath) -or -not (Test-Path (Join-Path $ScriptPath "lib"))) {
    $WorkDir = Join-Path $env:TEMP "FormatInstaller_Temp"
    Write-Host "Modo de execução remota/online detectado." -ForegroundColor Cyan
    Write-Host "Baixando última versão do repositório..." -ForegroundColor Cyan
    
    if (Test-Path $WorkDir) { Remove-Item -Path $WorkDir -Recurse -Force | Out-Null }
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
    
    $zipPath = Join-Path $WorkDir "format.zip"
    $repoZipUrl = "https://github.com/HeisenGod/format/archive/refs/heads/main.zip"
    
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $repoZipUrl -OutFile $zipPath -UseBasicParsing
    
    Expand-Archive -Path $zipPath -DestinationPath $WorkDir -Force
    
    $extractedFolder = Get-ChildItem -Path $WorkDir -Directory | Select-Object -First 1
    if ($extractedFolder) {
        $ScriptPath = $extractedFolder.FullName
        Set-Location -Path $ScriptPath
    } else {
        Write-Error "Não foi possível extrair os arquivos do repositório."
        exit
    }
}

Set-Location -Path $ScriptPath

# 3. Carregamento Modular de Bibliotecas
$libDir = Join-Path -Path $ScriptPath -ChildPath "lib"

. (Join-Path $libDir "Logger.ps1")
. (Join-Path $libDir "Utils.ps1")
. (Join-Path $libDir "Downloader.ps1")
. (Join-Path $libDir "Progress.ps1")
. (Join-Path $libDir "Installer.ps1")
. (Join-Path $libDir "UI.ps1")

# 4. Inicialização do Log e Interface
Initialize-Logger -BaseDirectory $ScriptPath
Write-Log "==== Iniciando Sessão do Format Installer ====" -Level "INFO"

# Auto-detecção de Aplicativos e Scripts na pasta /scripts
$tasks = Get-FormatTasks -BaseDir $ScriptPath

Write-Log "Encontradas $($tasks.Count) tarefas disponíveis." -Level "INFO"

# Abrir Interface Gráfica
Show-MainUI -Tasks $tasks -BaseDir $ScriptPath