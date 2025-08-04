function Crear-JavaSymlink {
    param (
        [string]$JavaRoot = "C:\Program Files\Java",
        [string]$LinkPath = "C:\ProgramData\Oracle\Java\javapath"
    )
    Write-Host "Intentando crear symlink de Java..." -ForegroundColor Yellow

    try {
        if (Test-Path $LinkPath) {
            Write-Host "Eliminando symlink existente: $LinkPath" -ForegroundColor Yellow
            Remove-Item -Path $LinkPath -Recurse -Force
        }

        if (-not (Test-Path $JavaRoot)) {
            Write-Host "No existe la carpeta $JavaRoot. No es posible crear symlink." -ForegroundColor Red
            return
        }

        $JavaFolders = Get-ChildItem -Path $JavaRoot -Directory | Where-Object { $_.Name -like "jre*" -or $_.Name -like "jdk*" }
        if (-not $JavaFolders) {
            Write-Host "No se encontró ninguna carpeta Java en $JavaRoot" -ForegroundColor Red
            return
        }
        $JavaFolder = $JavaFolders | Sort-Object Name -Descending | Select-Object -First 1
        $TargetPath = Join-Path $JavaFolder.FullName "bin"
        cmd /c "mklink /D `"$LinkPath`" `"$TargetPath`""
        Write-Host "Symlink creado: $LinkPath --> $TargetPath" -ForegroundColor Green
    } catch {
        Write-Host "Error al crear symlink de Java: $_" -ForegroundColor Red
    }
}

function Buscar-Java {
    $javaExe = $null

    # 1. Buscar en javapath
    $javapath = "C:\ProgramData\Oracle\Java\javapath\java.exe"
    if (Test-Path $javapath) {
        $javaExe = $javapath
    }
    # 2. Buscar en PATH
    elseif (Get-Command java.exe -ErrorAction SilentlyContinue) {
        $javaExe = (Get-Command java.exe).Source
    }
    # 3. Buscar en Program Files
    elseif (Test-Path "C:\Program Files\Java") {
        $folders = Get-ChildItem "C:\Program Files\Java" -Directory | Where-Object { $_.Name -like "jre*" -or $_.Name -like "jdk*" }
        foreach ($f in $folders) {
            $binPath = Join-Path $f.FullName "bin\java.exe"
            if (Test-Path $binPath) { $javaExe = $binPath; break }
        }
    }
    return $javaExe
}

try {
    $javaExe = Buscar-Java
    $javapathDir = "C:\ProgramData\Oracle\Java\javapath"

    if ($null -eq $javaExe) {
        Write-Host "Java NO encontrado en el sistema." -ForegroundColor Red

        $input = Read-Host "¿Deseas instalar Java automáticamente con winget? (S/N)"
        if ($input -eq "S" -or $input -eq "s") {
            Write-Host "Instalando Java con winget..." -ForegroundColor Yellow
            try {
                $wingetResult = Start-Process -FilePath "winget" -ArgumentList "install --accept-package-agreements --accept-source-agreements Oracle.JavaRuntimeEnvironment" -Wait -NoNewWindow -PassThru
                if ($wingetResult.ExitCode -eq 0) {
                    Write-Host "Java instalado correctamente." -ForegroundColor Green
                    Crear-JavaSymlink
                } else {
                    Write-Host "No se pudo instalar Java (código de error: $($wingetResult.ExitCode)).`n" -ForegroundColor Red
                }
            } catch {
                Write-Host "Error durante la instalación de Java con winget: $_`n" -ForegroundColor Red
            }
        } else {
            Write-Host "No se instalará Java. Finalizando comprobación.`n" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Java encontrado en: $javaExe" -ForegroundColor Green
        try {
            $version = & $javaExe -version 2>&1 | Select-Object -First 1
            Write-Host "Versión detectada: $version" -ForegroundColor Cyan
        } catch {
            Write-Host "Error al ejecutar java.exe" -ForegroundColor Yellow
        }
        # Crear symlink si no existe (aunque Java esté instalado en otra ruta)
        if (-not (Test-Path $javapathDir)) {
            Write-Host "Symlink $javapathDir no existe, se va a crear para compatibilidad...`n" -ForegroundColor Yellow
            Crear-JavaSymlink
        } else {
            Write-Host "Symlink $javapathDir ya existe.`n" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "Error inesperado durante la comprobación de Java: $_`n" -ForegroundColor Red
}
