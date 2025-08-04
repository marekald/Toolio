# Definir lista de usuarios estándar (puedes ajustar esta lista)
$usuariosEstandar = @(
    'Administrador',
    'DefaultAccount',
    'Invitado',
    'WDAGUtilityAccount'
	'defaultuser0'
)

# Obtener todos los usuarios locales
$usuariosLocales = Get-LocalUser | Select-Object -ExpandProperty Name

# Filtrar usuarios no estándar
$usuariosNoEstandar = $usuariosLocales | Where-Object { $_ -notin $usuariosEstandar }

# Mostrar alerta si hay usuarios no estándar
if ($usuariosNoEstandar.Count -gt 0) {
    Write-Host "ALERTA: Usuarios no estándar encontrados:`n" -ForegroundColor Red
    # Mostrar solo los nombres, uno por línea
    $usuariosNoEstandar | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "No se han encontrado usuarios no estándar.`n" -ForegroundColor Green
}
