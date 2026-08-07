# ==============================================================================
# Module: Downloader.ps1
# Description: Non-blocking web download engine with progress, speed & ETA
# ==============================================================================

function Start-FileDownload {
    param (
        [string]$Url,
        [string]$DestinationPath,
        [scriptblock]$OnProgress
    )

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.Timeout = 20000
        $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        
        $response = $request.GetResponse()
        $totalBytes = $response.ContentLength
        
        $responseStream = $response.GetResponseStream()
        $targetStream = [System.IO.File]::Create($DestinationPath)
        
        $buffer = New-Object byte[] 65536 # Buffer de 64 KB
        $downloadedBytes = 0
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        
        while (($bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $targetStream.Write($buffer, 0, $bytesRead)
            $downloadedBytes += $bytesRead
            
            $elapsedSeconds = $sw.Elapsed.TotalSeconds
            $speedBytesPerSec = if ($elapsedSeconds -gt 0) { $downloadedBytes / $elapsedSeconds } else { 0 }
            $percent = if ($totalBytes -gt 0) { [math]::Min(100, [math]::Round(($downloadedBytes / $totalBytes) * 100)) } else { 0 }
            
            $remainingBytes = [math]::Max(0, $totalBytes - $downloadedBytes)
            $etaSeconds = if ($speedBytesPerSec -gt 0) { [math]::Round($remainingBytes / $speedBytesPerSec) } else { 0 }

            if ($OnProgress) {
                & $OnProgress @{
                    Percent          = $percent
                    DownloadedBytes  = $downloadedBytes
                    TotalBytes       = $totalBytes
                    SpeedBytesPerSec = $speedBytesPerSec
                    EtaSeconds       = $etaSeconds
                }
            }
            [System.Windows.Forms.Application]::DoEvents()
        }
        
        $targetStream.Close()
        $responseStream.Close()
        $response.Close()
        $sw.Stop()
        return $true
    }
    catch {
        if ($targetStream) { $targetStream.Close() }
        if ($responseStream) { $responseStream.Close() }
        Write-Log "Falha no download de ($Url): $_" -Level "ERROR"
        return $false
    }
}