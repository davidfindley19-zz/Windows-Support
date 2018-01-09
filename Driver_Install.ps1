$MountPath = "C:\Users\findley\Documents\Deployments"
$driverFolder = "$MountPath\Dell Dock WD15"
$WindowsVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption

Test-Path $driverFolder

if($WindowsVersion.Contains("Windows 7")) 
{
    # Installing Drivers
    Write-Host "Installing WD-15 Ethernet Driver for Windows 7"
    $EtherPath = "$driverFolder\W7 x64\Ethernet"
    Start-Process -FilePath $EtherPath\RTNIC_DELL_INST.exe -Wait
    Write-Host "Installing WD-15 USB Driver for Windows 7"
    $UsbPath = "$driverFolder\W7 x64\USB"
    Start-Process $UsbPath\setup.exe -Wait
    Write-Host "Installing Wd-15 Audio Driver for Windows 7"
    $AudioPath = "$driverFolder\W7 x64\Audio"
    Start-Process -FilePath $AudioPath\DELLMUP.exe -Wait
}
else {
    Write-Host "Installing WD-15 Ethernet Driver for Windows 10"
    $driverFolder + "W10 x64\Realtek-USB-GBE-Ethernet-Controller-Driver_3XTRW_WIN_2.43.2017.505_A05_01\RTNIC_DELL_INST.exe"
    }
