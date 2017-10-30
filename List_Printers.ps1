#Prompts for Computer/User details. If nothing is entered, you will get errors
#But it will search your local machine.

$computer = Read-Host "Enter Computer Name: "
$user = read-host "Enter user name"


import-module Activedirectory


#Get Local Printers:
$Printers = @(Get-WmiObject win32_printer -computername $Computer | Select Name)
$users =  @(Get-WmiObject -ComputerName $Computer -Namespace root\cimv2 -Class Win32_ComputerSystem)[0].UserName

Write-Output $Printers | ft -Property @{Name="System Printers";Expression={$_.Name}} -AutoSize

#Get List of Network Printers:
$RegType = [Microsoft.Win32.RegistryHive]::Users
$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegType, $Computer)
$users = $Reg.GetSubKeyNames()
foreach ($user in $users) {
    try{
        $printers = @()
        $username = (get-aduser -filter "SID -eq '$user'" -Properties DisplayName).DisplayName
        $RegKey= $Reg.OpenSubKey("$user\Printers\Connections")
        $Printers += @($RegKey.GetSubKeyNames().replace(",,", "\\").Replace(",", "\"))
        write-host "$username's printers"
        write-host "-----------------------"
        Write-Output $Printers | ft -Property @{Name=" Printers";Expression={$_.Name}} -AutoSize
     } catch {}
}
