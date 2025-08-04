$servicioCS = Get-Service -Name "CSFalconService" -ErrorAction SilentlyContinue
if ($servicioCS) {
    if ($servicioCS.Status -eq "Running") {
        Write-Host "El servicio 'CSFalconService' está en ejecución." -ForegroundColor Green
    } else {
        Write-Host "El servicio 'CSFalconService' está detenido." -ForegroundColor Red
    }
} else {
    Write-Host "Servicio 'CSFalconService' no encontrado. CrowdStrike no está instalado." -ForegroundColor Red
}