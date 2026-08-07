# ==============================================================================
# Module: UI.ps1
# Description: Modern Dark-themed Windows Forms Graphical Interface
# ==============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-MainUI {
    param (
        [System.Collections.ArrayList]$Tasks,
        [string]$BaseDir
    )

    # Cores do Tema Escuro
    $bgDark      = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $panelDark   = [System.Drawing.Color]::FromArgb(37, 37, 38)
    $controlDark = [System.Drawing.Color]::FromArgb(50, 50, 52)
    $accentBlue  = [System.Drawing.Color]::FromArgb(0, 122, 204)
    $textLight   = [System.Drawing.Color]::FromArgb(241, 241, 241)
    $textSubtle  = [System.Drawing.Color]::FromArgb(160, 160, 160)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Windows Format Installer by HeisenGod"
    $form.Size = New-Object System.Drawing.Size(650, 720)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = $bgDark
    $form.ForeColor = $textLight
    $form.FormBorderStyle = "FixedSingle"
    $form.MaximizeBox = $false

    $iconPath = Join-Path -Path $BaseDir -ChildPath "assets\icon.ico"
    if (Test-Path $iconPath) {
        $form.Icon = New-Object System.Drawing.Icon($iconPath)
    }

    # Header Panel
    $pnlHeader = New-Object System.Windows.Forms.Panel
    $pnlHeader.Size = New-Object System.Drawing.Size(650, 60)
    $pnlHeader.Dock = "Top"
    $pnlHeader.BackColor = $panelDark
    $form.Controls.Add($pnlHeader)

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Windows Format Installer"
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    $lblTitle.ForeColor = $textLight
    $lblTitle.Location = New-Object System.Drawing.Point(20, 10)
    $lblTitle.AutoSize = $true
    $pnlHeader.Controls.Add($lblTitle)

    $lblSubtitle = New-Object System.Windows.Forms.Label
    $lblSubtitle.Text = "by HeisenGod"
    $lblSubtitle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
    $lblSubtitle.ForeColor = $accentBlue
    $lblSubtitle.Location = New-Object System.Drawing.Point(22, 34)
    $lblSubtitle.AutoSize = $true
    $pnlHeader.Controls.Add($lblSubtitle)

    # Lista de Tarefas (ListView)
    $listTasks = New-Object System.Windows.Forms.ListView
    $listTasks.View = [System.Windows.Forms.View]::Details
    $listTasks.CheckBoxes = $true
    $listTasks.FullRowSelect = $true
    $listTasks.BackColor = $panelDark
    $listTasks.ForeColor = $textLight
    $listTasks.Location = New-Object System.Drawing.Point(20, 75)
    $listTasks.Size = New-Object System.Drawing.Size(595, 250)
    $listTasks.BorderStyle = "FixedSingle"
    $listTasks.Columns.Add("Aplicativo / Configuração", 380) | Out-Null
    $listTasks.Columns.Add("Status", 190) | Out-Null

    foreach ($task in $Tasks) {
        $item = New-Object System.Windows.Forms.ListViewItem($task.Name)
        $item.SubItems.Add($task.Status) | Out-Null
        $item.Checked = $task.IsChecked
        $item.Tag = $task
        $listTasks.Items.Add($item) | Out-Null
    }
    $form.Controls.Add($listTasks)

    # Progresso Individual
    $lblCurrentApp = New-Object System.Windows.Forms.Label
    $lblCurrentApp.Location = New-Object System.Drawing.Point(20, 340)
    $lblCurrentApp.Size = New-Object System.Drawing.Size(595, 20)
    $lblCurrentApp.Text = "Aplicativo atual: Aguardando seleção..."
    $lblCurrentApp.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($lblCurrentApp)

    $pbIndividual = New-Object System.Windows.Forms.ProgressBar
    $pbIndividual.Location = New-Object System.Drawing.Point(20, 365)
    $pbIndividual.Size = New-Object System.Drawing.Size(595, 22)
    $form.Controls.Add($pbIndividual)

    $lblIndStats = New-Object System.Windows.Forms.Label
    $lblIndStats.Location = New-Object System.Drawing.Point(20, 393)
    $lblIndStats.Size = New-Object System.Drawing.Size(595, 20)
    $lblIndStats.Text = "0 MB / 0 MB  |  Velocidade: 0 MB/s  |  Tempo restante: 0s"
    $lblIndStats.ForeColor = $textSubtle
    $form.Controls.Add($lblIndStats)

    # Separador
    $pnlSep = New-Object System.Windows.Forms.Panel
    $pnlSep.Location = New-Object System.Drawing.Point(20, 422)
    $pnlSep.Size = New-Object System.Drawing.Size(595, 1)
    $pnlSep.BackColor = $controlDark
    $form.Controls.Add($pnlSep)

    # Progresso Geral
    $lblOverallTitle = New-Object System.Windows.Forms.Label
    $lblOverallTitle.Location = New-Object System.Drawing.Point(20, 432)
    $lblOverallTitle.Size = New-Object System.Drawing.Size(595, 20)
    $lblOverallTitle.Text = "Progresso Geral"
    $lblOverallTitle.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($lblOverallTitle)

    $pbOverall = New-Object System.Windows.Forms.ProgressBar
    $pbOverall.Location = New-Object System.Drawing.Point(20, 457)
    $pbOverall.Size = New-Object System.Drawing.Size(595, 22)
    $form.Controls.Add($pbOverall)

    $lblOverallTasks = New-Object System.Windows.Forms.Label
    $lblOverallTasks.Location = New-Object System.Drawing.Point(20, 485)
    $lblOverallTasks.Size = New-Object System.Drawing.Size(595, 20)
    $lblOverallTasks.Text = "0 de 0 tarefas concluídas"
    $lblOverallTasks.ForeColor = $textSubtle
    $form.Controls.Add($lblOverallTasks)

    # Status
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Location = New-Object System.Drawing.Point(20, 520)
    $lblStatus.Size = New-Object System.Drawing.Size(595, 25)
    $lblStatus.Text = "Status: Aguardando início..."
    $lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
    $lblStatus.ForeColor = $accentBlue
    $form.Controls.Add($lblStatus)

    # Botões
    $btnInstall = New-Object System.Windows.Forms.Button
    $btnInstall.Text = "Instalar"
    $btnInstall.Location = New-Object System.Drawing.Point(375, 615)
    $btnInstall.Size = New-Object System.Drawing.Size(115, 38)
    $btnInstall.BackColor = $accentBlue
    $btnInstall.FlatStyle = "Flat"
    $btnInstall.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $btnInstall.ForeColor = [System.Drawing.Color]::White
    $btnInstall.FlatAppearance.BorderSize = 0
    $form.Controls.Add($btnInstall)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancelar"
    $btnCancel.Location = New-Object System.Drawing.Point(500, 615)
    $btnCancel.Size = New-Object System.Drawing.Size(115, 38)
    $btnCancel.BackColor = $controlDark
    $btnCancel.FlatStyle = "Flat"
    $btnCancel.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
    $btnCancel.ForeColor = $textLight
    $btnCancel.FlatAppearance.BorderSize = 0
    $form.Controls.Add($btnCancel)

    $script:IsCancelling = $false

    $btnCancel.Add_Click({
        if ($btnInstall.Enabled -eq $false) {
            $script:IsCancelling = $true
            $lblStatus.Text = "Status: Cancelamento solicitado... Aguarde finalizar a tarefa atual."
        } else {
            $form.Close()
        }
    })

    $btnInstall.Add_Click({
        $selectedItems = @($listTasks.Items | Where-Object { $_.Checked })
        if ($selectedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Selecione ao menos um item para instalar.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        $btnInstall.Enabled = $false
        $listTasks.Enabled = $false
        $script:IsCancelling = $false

        $totalSelected = $selectedItems.Count
        $completedCount = 0

        for ($i = 0; $i -lt $totalSelected; $i++) {
            if ($script:IsCancelling) {
                Write-Log "Instalação cancelada pelo usuário." -Level "WARNING"
                $lblStatus.Text = "Status: Instalação cancelada."
                break
            }

            $item = $selectedItems[$i]
            $task = $item.Tag

            $lblCurrentApp.Text = "Aplicativo atual: $($task.Name)"
            $lblStatus.Text = "Status: Processando $($task.Name)..."

            Invoke-TaskExecution -Task $task -BaseDir $BaseDir -UpdateUI {
                param($data)
                
                if ($data.Status) { $item.SubItems[1].Text = $data.Status }
                if ($data.Percent -ne $null) { $pbIndividual.Value = $data.Percent }
                
                if ($data.Speed -ne $null -and $data.Total -ne $null) {
                    $dlStr = Format-Bytes $data.Downloaded
                    $totStr = Format-Bytes $data.Total
                    $speedStr = "$(Format-Bytes $data.Speed)/s"
                    $lblIndStats.Text = "$dlStr / $totStr  |  Velocidade: $speedStr  |  Tempo restante: $($data.Eta)s"
                }
                [System.Windows.Forms.Application]::DoEvents()
            }

            $completedCount++
            $overallPct = Get-OverallProgress -CompletedTasks $completedCount -TotalTasks $totalSelected
            $pbOverall.Value = $overallPct
            $lblOverallTasks.Text = "$completedCount de $totalSelected tarefas concluídas ($overallPct%)"
        }

        if (-not $script:IsCancelling) {
            $lblStatus.Text = "Status: Todas as instalações foram concluídas!"
            Write-Log "Todas as tarefas selecionadas foram processadas." -Level "SUCCESS"
            [System.Windows.Forms.MessageBox]::Show("Processo finalizado com sucesso!", "Format Installer", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }

        $btnInstall.Enabled = $true
        $listTasks.Enabled = $true
    })

    $form.ShowDialog() | Out-Null
}