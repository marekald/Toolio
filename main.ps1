# main.ps1
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$checksFolder = Join-Path $scriptPath "checks"
$logFolder = Join-Path $scriptPath "log"

# Crear carpeta log si no existe
if (!(Test-Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder | Out-Null
}

# Nombre del log: Equipo_FechaHora.log (guion bajo NORMAL)
$hostname = $env:COMPUTERNAME
$datetime = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logFolder ("{0}_{1}.log" -f $hostname, $datetime)

# Lista de scripts
$scripts = @(
    "Check_Dominio.ps1",
    "Check_Java.ps1",
    "Check_PCName.ps1",
    "Check_users.ps1",
	"Check_software.ps1",
	"Check_Crowdstrike.ps1",
	"Check_WU.ps1"
)

foreach ($script in $scripts) {
    $fullPath = Join-Path $checksFolder $script
    $header = "========== Ejecutando $script =========="
    Write-Host $header -ForegroundColor Cyan
    Add-Content $logFile $header

    if (Test-Path $fullPath) {
        try {
            $output = & "$fullPath" 2>&1
            $output | ForEach-Object {
                Write-Host $_
                Add-Content $logFile $_
            }
            Add-Content $logFile "----------------------------------------`n"
        }
        catch {
            $errMsg = $_.Exception.Message
            Write-Host $errorMsg -ForegroundColor Red
            Add-Content $logFile $errorMsg
        }
    } else {
        $notFoundMsg = "No se encontró el script $script"
        Write-Host $notFoundMsg -ForegroundColor Yellow
        Add-Content $logFile $notFoundMsg
    }
}

Write-Host "`nFinalizado. Log guardado en: $logFile`n" -ForegroundColor Green
