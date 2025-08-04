# Lista de rutas a verificar (puedes modificar)
$rutasProhibidas = @(
    "C:\ProgramData\Package Cache\{CE71B7CE-1583-404D-9D98-31094EFD1794}\Intel-Driver-and-Support-Assistant-Installer.exe"
    ##"C:\nvidia no me se la ruta"
)

$encontrados = @()
foreach ($ruta in $rutasProhibidas) {
    if (Test-Path $ruta) {
        $encontrados += $ruta
    }
}

if ($encontrados.Count -gt 0) {
    Write-Host "Se han encontrado las siguientes rutas prohibidas:" -ForegroundColor Red
    $encontrados | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    # Preguntar si eliminar (puedes automatizarlo si quieres)
	$eliminar = Read-Host "¿Quieres eliminar los programas encontrados? (s/n)"
	if ($eliminar -eq "s") {
		foreach ($ruta in $encontrados) {
			# Ejecuta el desinstalador con argumentos (ajusta si el programa necesita otros)
			Start-Process -FilePath $ruta -ArgumentList "/uninstall /SILENT /VERYSILENT" -Wait
			Write-Host "Intentando eliminar $ruta..." -ForegroundColor Cyan
		}
		Write-Host "Procesos de desinstalación lanzados." -ForegroundColor Green
	} else {
		Write-Host "No se ha eliminado nada."
	}
	exit 1

} else {
    Write-Host "Todo correcto. No se han encontrado rutas prohibidas." -ForegroundColor Green
    exit 0
}
