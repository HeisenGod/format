# ==============================================================================
# Module: Installer.ps1
# Description: Auto-discovers apps and scripts (.bat/.ps1) & manages installation
# ==============================================================================

function Get-FormatTasks {
    param (
        [string]$BaseDir = "$PSScriptRoot/.."
    )
    
    $tasks = @()
    
    # --------------------------------------------------------------------------
    # 1. AUTO-DETECÇÃO AUTOMÁTICA DE SCRIPTS (.bat / .ps1) em scripts/
    # --------------------------------------------------------------------------
    $scriptsDir = Join-Path -Path $BaseDir -ChildPath "scripts"
    if (Test-Path -Path $scriptsDir) {
        $scriptFiles = Get-ChildItem -Path $scriptsDir -File | Where-Object { $_.Extension -match "\.(bat|ps1)$" }
        foreach ($file in $scriptFiles) {
            # Converte o nome do arquivo para um título limpo (ex: MostrarExtensoes -> Mostrar Extensoes)
            $displayName = $file.BaseName -replace '([a-z])([A-Z])', '$1 $2'
            $tasks += [PSCustomObject]@{
                Type        = "Script"
                Name        = $displayName
                Category    = "Configuração do Sistema"
                Path        = $file.FullName
                Status      = "⏳ Aguardando"
                IsChecked   = $true
            }
        }
    }
    
    # --------------------------------------------------------------------------
    # 2. AUTO-DETECÇÃO DE APLICATIVOS em apps/ (lendo app.json)
    # --------------------------------------------------------------------------
    $appsDir = Join-Path -Path $BaseDir -ChildPath "apps"
    if (Test-Path -Path $appsDir) {
        $appFolders = Get-ChildItem -Path $appsDir -Directory
        foreach ($folder in $appFolders) {
            $jsonPath = Join-Path -Path $folder.FullName -ChildPath "app.json"
            if (Test-Path -Path $jsonPath) {
                try {
                    $json = Get-Content -Path $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
                    $tasks += [PSCustomObject]@{
                        Type        = "App"
                        Name        = $json.name
                        Category    = if ($json.category) { $json.category } else { "Geral" }
                        Check       = $json.check
                        Download    = $json.download
                        Installer   = $json.installer
                        Arguments   = $json.arguments
                        PostInstall = $json.postInstall
                        Folder      = $folder.FullName
                        Status      = "⏳ Aguardando"
                        IsChecked   = $true
                    }
                } catch {
                    Write-Log "Erro ao carregar app.json em $($folder.Name): $_" -Level "WARNING"
                }
            }
        }
    }
    
    return $tasks
}

function Invoke-TaskExecution {
    param (
        [PSCustomObject]$Task,
        [string]$BaseDir,
        [scriptblock]$UpdateUI
    )
    
    & $UpdateUI @{ Status = "🔍 Verificando..."; Percent = 0 }
    
    # Execução de Script .bat ou .ps1
    if ($Task.Type -eq "Script") {
        Write-Log "Executando script: $($Task.Name) ($($Task.Path))" -Level "INFO"
        & $UpdateUI @{ Status = "⚙ Aplicando..."; Percent = 50 }
        
        try {
            if ($Task.Path.EndsWith(".bat", [System.StringComparison]::OrdinalIgnoreCase)) {
                $p = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$($Task.Path)`"" -Wait -PassThru -WindowStyle Hidden
            } else {
                $p = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($Task.Path)`"" -Wait -PassThru -WindowStyle Hidden
            }
            
            & $UpdateUI @{ Status = "✓ Concluído"; Percent = 100 }
            Write-Log "Script $($Task.Name) concluído com sucesso." -Level "SUCCESS"
            return
        } catch {
            & $UpdateUI @{ Status = "❌ Erro"; Percent = 0 }
            Write-Log "Erro ao executar script $($Task.Name): $_" -Level "ERROR"
            return
        }
    }

    # Execução de Aplicativo
    if (Test-AppInstalled -CheckPath $Task.Check -AppName $Task.Name) {
        & $UpdateUI @{ Status = "✓ Já instalado"; Percent = 100 }
        Write-Log "Aplicativo $($Task.Name) já instalado. Ignorando download..." -Level "INFO"
        return
    }

    $downloadDir = Join-Path -Path $BaseDir -ChildPath "downloads"
    if (-not (Test-Path $downloadDir)) { New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null }
    
    $localFile = Join-Path -Path $downloadDir -ChildPath $Task.Installer

    # Download do executável
    if (-not [string]::IsNullOrWhiteSpace($Task.Download)) {
        & $UpdateUI @{ Status = "↓ Baixando..."; Percent = 0 }
        Write-Log "Iniciando download do aplicativo: $($Task.Name)" -Level "INFO"
        
        $downloadSuccess = Start-FileDownload -Url $Task.Download -DestinationPath $localFile -OnProgress {
            param($p)
            & $UpdateUI @{
                Status       = "↓ Baixando... $($p.Percent)%"
                Percent      = $p.Percent
                Downloaded   = $p.DownloadedBytes
                Total        = $p.TotalBytes
                Speed        = $p.SpeedBytesPerSec
                Eta          = $p.EtaSeconds
            }
        }

        if (-not $downloadSuccess) {
            & $UpdateUI @{ Status = "❌ Erro"; Percent = 0 }
            Write-Log "Download falhou para $($Task.Name). Continuando para o próximo item..." -Level "ERROR"
            return
        }
    }

    # Instalação silenciosa
    & $UpdateUI @{ Status = "⚙ Instalando..."; Percent = 100 }
    Write-Log "Instalando $($Task.Name)..." -Level "INFO"
    
    try {
        if (Test-Path $localFile) {
            $process = Start-Process -FilePath $localFile -ArgumentList $Task.Arguments -Wait -PassThru -NoNewWindow
            Write-Log "Instalação do $($Task.Name) finalizada (ExitCode: $($process.ExitCode))." -Level "INFO"
        }
    } catch {
        & $UpdateUI @{ Status = "❌ Erro"; Percent = 0 }
        Write-Log "Erro na instalação de $($Task.Name): $_" -Level "ERROR"
        return
    }

    # Execução de Script pós-instalação (se configurado)
    if ($Task.PostInstall) {
        $customInstallScript = Join-Path -Path $Task.Folder -ChildPath "install.ps1"
        if (Test-Path $customInstallScript) {
            & $UpdateUI @{ Status = "📂 Aplicando perfil..."; Percent = 100 }
            Write-Log "Aplicando configurações pós-instalação para $($Task.Name)..." -Level "INFO"
            try {
                & $customInstallScript
                Write-Log "Perfil aplicado para $($Task.Name)." -Level "SUCCESS"
            } catch {
                Write-Log "Erro no perfil de pós-instalação de $($Task.Name): $_" -Level "ERROR"
            }
        }
    }

    & $UpdateUI @{ Status = "✓ Concluído"; Percent = 100 }
    Write-Log "Instalação concluída com sucesso para $($Task.Name)." -Level "SUCCESS"
}