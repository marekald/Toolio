$nombreEquipo = $env:COMPUTERNAME
if ($nombreEquipo -like "*MININT*") {
    Write-Host "ALERTA: El nombre del equipo contiene 'MININT' -> $nombreEquipo`n" -ForegroundColor Red
} else {
    Write-Host "Nombre: $nombreEquipo`n" -ForegroundColor Green
}
