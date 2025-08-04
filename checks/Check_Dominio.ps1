try {
    $dominio = (Get-WmiObject Win32_ComputerSystem).Domain
    if ($dominio -eq "deusto.es") {
        Write-Host "Dominio correcto: $dominio`n" -ForegroundColor Green
    } else {
        Write-Host "ALERTA: Dominio incorrecto o no unido a dominio -> $dominio`n" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: No se pudo obtener información del dominio.`n" -ForegroundColor Red
}
