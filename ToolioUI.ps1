Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Get-SystemInfo {
    $computerName = $env:COMPUTERNAME
    $domain = (Get-WmiObject Win32_ComputerSystem).Domain
    $ip = (Get-NetIPConfiguration | Where-Object { $_.NetProfile.Name -eq "deusto.es"} | Select-Object -ExpandProperty IPv4Address | Select-Object -ExpandProperty IPAddress)
    $mac = (Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.InterfaceDescription -notmatch "VirtualBox|VMware|Bluetooth"} | Select-Object -First 1 -ExpandProperty MacAddress)
    $brand = (Get-WmiObject Win32_BIOS).Manufacturer
    $model = (Get-WmiObject Win32_ComputerSystem).Model
    $serial = (Get-WmiObject Win32_BIOS).SerialNumber

    return @{
        ComputerName = $computerName
        Domain = $domain
        IP = $ip
        MAC = $mac
        Brand = $brand
        Model = $model
        Serial = $serial
    }
}

$ScriptPaths = @{
    "CheckUsers"       = Join-Path $BasePath "checks\check_users.ps1"
    "CheckWU"          = Join-Path $BasePath "checks\check_WU.ps1"
    "CheckCrowdstrike" = Join-Path $BasePath "checks\check_Crowdstrike.ps1"
    "CheckJava"        = Join-Path $BasePath "checks\check_Java.ps1"
    "CheckSoftware"    = Join-Path $BasePath "checks\check_software.ps1"
}

function Invoke-Script {
    param($ScriptPath, $OutputBlock)
	$OutputBlock.Foreground = 'White'
	$OutputBlock.Text = "Ejecutando... $ScriptPath"
	[System.Windows.Forms.Application]::DoEvents() # Fuerza refresco de la UI
	Try {
		if (Test-Path $ScriptPath) {
    	    $result = powershell.exe -ExecutionPolicy Bypass -File $ScriptPath 2>&1
    	    $OutputBlock.Foreground = 'LightGreen'
    		$OutputBlock.Text = "Correcto: $result"
    	} else {
    	    $OutputBlock.Foreground = 'Red'
    	    $OutputBlock.Text = "Error: Script no encontrado en $ScriptPath"
    	}
    } Catch {
        $OutputBlock.Foreground = 'Red'
        $OutputBlock.Text = "Error al ejecutar el script: $ScriptPath"
    }
}

$XamlPath = Join-Path $BasePath "UI.xaml"
[xml]$XAML = Get-Content $XamlPath -Raw

$reader = (New-Object System.Xml.XmlNodeReader $XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

$lblComputerName   = $Window.FindName("ComputerName")
$lblDomain         = $Window.FindName("Domain")
$lblIP             = $Window.FindName("IP")
$lblMAC            = $Window.FindName("MAC")
$lblBrand          = $Window.FindName("Brand")
$lblModel          = $Window.FindName("Model")
$lblSerial         = $Window.FindName("Serial")
$btnCheckUsers     = $Window.FindName("btnCheckUsers")
$btnCheckWU        = $Window.FindName("btnCheckWU")
$btnCheckCrowdstrike = $Window.FindName("btnCheckCrowdstrike")
$btnCheckJava      = $Window.FindName("btnCheckJava")
$btnCheckSoftware  = $Window.FindName("btnCheckSoftware")
$txtOutput         = $Window.FindName("txtOutput")

$info = Get-SystemInfo
$lblComputerName.Text = "Nombre: $($info.ComputerName)"
$lblDomain.text       = "Domain: $($info.Domain)"
$lblIP.Text           = "IP: $($info.IP)"
$lblMAC.Text          = "MAC: $($info.MAC)"
$lblBrand.Text        = "Marca: $($info.Brand)"
$lblModel.Text        = "Modelo: $($info.Model)"
$lblSerial.Text       = "Serie: $($info.Serial)"

$btnCheckUsers.Add_Click({Invoke-Script -ScriptPath $ScriptPaths.CheckUsers -OutputBlock $txtOutput})
$btnCheckWU.Add_Click({Invoke-Script -ScriptPath $ScriptPaths.CheckWU -OutputBlock $txtOutput})
$btnCheckCrowdstrike.Add_Click({Invoke-Script -ScriptPath $ScriptPaths.CheckCrowdstrike -OutputBlock $txtOutput})
$btnCheckJava.Add_Click({Invoke-Script -ScriptPath $ScriptPaths.CheckJava -OutputBlock $txtOutput})
$btnCheckSoftware.Add_Click({Invoke-Script -ScriptPath $ScriptPaths.CheckSoftware -OutputBlock $txtOutput})

$Window.ShowDialog() | Out-Null
