$usuariosEstandar = @(
    'Administrador',
    'DefaultAccount',
    'Invitado',
    'WDAGUtilityAccount',
    'defaultuser0'
)

$usuariosLocales = Get-LocalUser | Select-Object -ExpandProperty Name
$usuariosNoEstandar = $usuariosLocales | Where-Object { $_ -notin $usuariosEstandar }

if ($usuariosNoEstandar.Count -gt 0) {
    Write-Output "ALERTA: Usuarios no estándar encontrados:`n"
    $usuariosNoEstandar | ForEach-Object { Write-Output $_ }
} else {
    Write-Output "No se han encontrado usuarios no estándar.`n"
}
