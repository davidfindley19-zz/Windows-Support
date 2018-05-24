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
    $USBPath = "$driverFolder\W7 x64\USB"
    Start-Process $UsbPath\setup.exe -Wait
    Write-Host "Installing Wd-15 Audio Driver for Windows 7"
    $AudioPath = "$driverFolder\W7 x64\Audio"
    Start-Process -FilePath $AudioPath\DELLMUP.exe -Wait
}
else {
    Write-Host "Installing WD-15 Ethernet Driver for Windows 10"
    $EtherPath = "$driverFolder\W10 x64\setup.exe "
    Start-Process $EtherPath\setup.exe -Wait
    Write-Host "Installing WD-15 USB Driver for Windows 10 "
    $USBPath = "$driverFolder\W10 x64\USB"
    Start-Process $USBPath\setup.exe -Wait
    Write-Host "Installing WD-15 Audio Driver for Windows 10"
    $AudioPath = "$driverFolder\W10 x64\Audio"
    Start-Process $AudioPath\setup.exe -Wait
}

Write-Host "All drivers have been installed."
exit 
