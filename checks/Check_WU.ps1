try {
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $updates = $searcher.Search("IsInstalled=0").Updates
    if ($updates.Count -eq 0) {
        Write-Host "No hay actualizaciones pendientes." -ForegroundColor Green
    } else {
        Write-Host "Actualizaciones encontradas:" -ForegroundColor Yellow
        $updates | ForEach-Object { Write-Host " - $($_.Title)" -ForegroundColor Yellow }
    }
} catch {
    Write-Host "No se pudo comprobar actualizaciones." -ForegroundColor Red
}