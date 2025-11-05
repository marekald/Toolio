$usuariosEstandar = @(
	'Administrador',
	'DefaultAccount',
	'Invitado',
	'WDAGUtilityAccount',
	'defaultuser0'
)

$usuariosLocales = Get-LocalUser | Select-Object Name, Enabled
$usuariosNoEstandar = $usuariosLocales | Where-Object { $_.Name -notin $usuariosEstandar }

if ($usuariosEstandar.Count -gt 0) {
	write-Output "Usuario no permitido encontrado."

}

if ($usuariosNoEstandar.Count -gt 0) {
	Write-Output "Usuarios no estándar encontrados:`n"
	$usuariosNoEstandar | ForEach-Object { 
		$estado = if ($_.Enabled) { "HABILITADO" } else { "deshabilitado" }
		Write-Output "$($_.Name) - $estado"
	}
} else {
	Write-Output "No se han encontrado usuarios no estándar.`n"
}
