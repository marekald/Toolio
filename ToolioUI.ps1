# Cargar librerías necesarias para la interfaz
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Obtener la ruta base del script actual, para ubicar la carpeta checks
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# ==========================================
# Función: Get-SystemInfo
# Descripción: Recopila información clave del sistema, incluyendo nombre, IP, MAC, modelo y número de serie.
# ==========================================
function Get-SystemInfo {
    $computerName = $env:COMPUTERNAME
    $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Ethernet','Wi-Fi' -ErrorAction SilentlyContinue | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object -First 1 -ExpandProperty IPAddress)
    $mac = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1 -ExpandProperty MacAddress)
    $model = (Get-WmiObject Win32_ComputerSystem).Model
    $serial = (Get-WmiObject Win32_BIOS).SerialNumber
    return @{
        ComputerName = $computerName
        IP = $ip
        MAC = $mac
        Model = $model
        Serial = $serial
    }
}

# ==========================================
# Diccionario de rutas a los scripts de checks
# Descripción: Asocia cada botón con el script correspondiente en la carpeta checks.
# ==========================================
$ScriptPaths = @{
    "CheckUsers"       = Join-Path $BasePath "checks\Check_users.ps1"
    "CheckWU"          = Join-Path $BasePath "checks\Check_WU.ps1"
    "CheckCrowdstrike" = Join-Path $BasePath "checks\Check_Crowdstrike.ps1"
    "CheckDominio"     = Join-Path $BasePath "checks\Check_Dominio.ps1"
    "CheckJava"        = Join-Path $BasePath "checks\Check_Java.ps1"
    "CheckPCName"      = Join-Path $BasePath "checks\Check_PCName.ps1"
    "CheckSoftware"    = Join-Path $BasePath "checks\Check_software.ps1"
}

# ==========================================
# Función: Run-Script
# Descripción: Ejecuta el script indicado y muestra el resultado en la interfaz.
# Da feedback de éxito o error, incluyendo el resultado del script.
# ==========================================
function Run-Script {
    param($ScriptPath, $OutputBlock)
    Try {
        if (Test-Path $ScriptPath) {
            $result = powershell.exe -ExecutionPolicy Bypass -File $ScriptPath 2>&1
            $OutputBlock.Text = "✅ Éxito:`n$result"
        } else {
            $OutputBlock.Text = "❌ Error: Script no encontrado en $ScriptPath"
        }
    } Catch {
        $OutputBlock.Text = "❌ Error al ejecutar el script:`n$_"
    }
}

# ==========================================
# Definición de la interfaz gráfica en XAML
# Descripción: Ventana moderna y minimalista con botones para cada chequeo.
# ==========================================
$XamlPath = Join-Path $BasePath "Interfaz.xaml"
[xml]$XAML = Get-Content $XamlPath -Raw

# ==========================================
# Carga la ventana desde el XAML y enlaza controles
# ==========================================
$reader = (New-Object System.Xml.XmlNodeReader $XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Enlaza los objetos de la interfaz a variables para su manipulación
$lblComputerName   = $Window.FindName("lblComputerName")
$lblIP             = $Window.FindName("lblIP")
$lblMAC            = $Window.FindName("lblMAC")
$lblModel          = $Window.FindName("lblModel")
$lblSerial         = $Window.FindName("lblSerial")
$btnCheckUsers     = $Window.FindName("btnCheckUsers")
$btnCheckWU        = $Window.FindName("btnCheckWU")
$btnCheckCrowdstrike = $Window.FindName("btnCheckCrowdstrike")
$btnCheckDominio   = $Window.FindName("btnCheckDominio")
$btnCheckJava      = $Window.FindName("btnCheckJava")
$btnCheckPCName    = $Window.FindName("btnCheckPCName")
$btnCheckSoftware  = $Window.FindName("btnCheckSoftware")
$txtOutput         = $Window.FindName("txtOutput")

# ==========================================
# Muestra la información del sistema al arrancar
# ==========================================
$info = Get-SystemInfo
$lblComputerName.Text = "Nombre: $($info.ComputerName)"
$lblIP.Text           = "IP: $($info.IP)"
$lblMAC.Text          = "MAC: $($info.MAC)"
$lblModel.Text        = "Modelo: $($info.Model)"
$lblSerial.Text       = "Serie: $($info.Serial)"

# ==========================================
# Define las acciones de cada botón de chequeo
# Cada uno ejecuta su script y muestra el resultado
# ==========================================
$btnCheckUsers.Add_Click(       { Run-Script -ScriptPath $ScriptPaths.CheckUsers       -OutputBlock $txtOutput })
$btnCheckWU.Add_Click(          { Run-Script -ScriptPath $ScriptPaths.CheckWU          -OutputBlock $txtOutput })
$btnCheckCrowdstrike.Add_Click( { Run-Script -ScriptPath $ScriptPaths.CheckCrowdstrike -OutputBlock $txtOutput })
$btnCheckDominio.Add_Click(     { Run-Script -ScriptPath $ScriptPaths.CheckDominio     -OutputBlock $txtOutput })
$btnCheckJava.Add_Click(        { Run-Script -ScriptPath $ScriptPaths.CheckJava        -OutputBlock $txtOutput })
$btnCheckPCName.Add_Click(      { Run-Script -ScriptPath $ScriptPaths.CheckPCName      -OutputBlock $txtOutput })
$btnCheckSoftware.Add_Click(    { Run-Script -ScriptPath $ScriptPaths.CheckSoftware    -OutputBlock $txtOutput })

# ==========================================
# Muestra la ventana principal de la aplicación
# ==========================================
$Window.ShowDialog() | Out-Null
