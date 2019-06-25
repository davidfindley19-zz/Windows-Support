<#
    .SYNOPSIS
        Scripted promotion of a new Domain Controller.
    .DESCRIPTION
        A script written to promote a new domain controller on an existing domain. This is not a script to create a 
        new domain. 
    .NOTES
        Author:     David Findley (Excerpts from Uzii3 on Technet.)
        Date:       6/7/2019
        Version:    1.0   
        Change Log: 
                    1.0 (6/7) Initial version of the script. 
#>

[CmdletBinding()]
param(
[Parameter(Mandatory=$false)]
[string]$ComputerName
)

if([string]::IsNullOrEmpty($ComputerName))
    {
        $ComputerName = $env:COMPUTERNAME
    }

$Credentials = Get-Credential -Message `n"Enter your Domain Admin account details."

Clear-Host
Write-Host "Promote a new Domain Controller" `n 
Write-Host "Please wait while server information is being collected..." -ForegroundColor DarkGreen `n

$OperatingSystem = Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName | Select-Object *
$HardwareInformation = Get-CimInstance Win32_ComputerSystem -ComputerName $ComputerName | Select-Object *
$MemoryInformation = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName).TotalPhysicalMemory/1GB)
$ProcessorInformation = Get-CimInstance Win32_Processor -ComputerName $ComputerName | Select-Object *

Write-Host "System Name:"$ComputerName -ForegroundColor White
Write-Host "Manufactured by:"$HardwareInformation.Manufacturer -ForegroundColor White
Write-Host "Hardware Model:"$HardwareInformation.Model -ForegroundColor White
Write-Host "Processor:"$ProcessorInformation.Name -ForegroundColor White
Write-Host "Installed RAM:"$MemoryInformation "GB" -ForegroundColor White
Write-Host "Domain:"$HardwareInformation.Domain -ForegroundColor White
Write-Host "OS Version:"$OperatingSystem.Caption -ForegroundColor White
Write-Host "OS Architecture:"$OperatingSystem.OSArchitecture -ForegroundColor White

Do {
    Write-Host `n"Based on the hardware configuration above, would you like to continue with the DC Promotion?" -ForegroundColor Yellow
    $Input = Read-Host "(Y/N)?" 
}
Until (($Input -eq "Y") -or ($Input -eq "N"))
    If ($Input -eq "Y"){
        Out-Null
    }
    elseif ($Input -eq "N") {
        Write-Host `n"User has selected to cancel the DC Promotion. Exiting." -ForegroundColor Red
        Start-Sleep -Seconds 2
        Exit
    }
Write-Host `n"Will this server need the DHCP role installed?" -ForegroundColor Yellow
$DHCPResponse = Read-Host "(Y/N)?"

Write-Host `n"Checking ADDS installation state..." -ForegroundColor DarkGreen `n
$InstalledState = (Get-WindowsFeature -Name ad-domain-services).installstate

if ($InstalledState -ne "Installed") {
    Write-Host `n"Installing ADDS roles... Please wait..." 
    Install-WindowsFeature -Name ad-domain-services
    Start-Sleep -Seconds 3

    $InstalledStateCheck = (Get-WindowsFeature -Name ad-domain-services).installstate

    if ($InstalledStateCheck -ne "Installed") {
        Write-Warning "ADDS role installation failed. Please check the logs or install manually."
    }
    elseif ($InstalledStateCheck -eq "Installed") {
        Write-Host "ADDS role installation completed. Proceeding with DNS check." 
    }
}
else {
    Write-Host `n"ADDS role is already installed. Proceeding with DNS check." 
}

Write-Host `n"Checking DNS role installation state..." -ForegroundColor DarkGreen
$InstalledState = (Get-WindowsFeature -Name DNS).installstate

if ($InstalledState -ne "Installed") {
    Write-Host `n"Installing DNS roles... Please wait..." 
    Install-WindowsFeature -Name DNS
    Start-Sleep -Seconds 3

    $InstalledStateCheck = (Get-WindowsFeature -Name DNS).installstate

    if ($InstalledStateCheck -ne "Installed") {
        Write-Warning "DNS role installation failed. Please check logs or install manually."
    }
    elseif ($InstalledStateCheck -eq "Installed") {
        Write-Host `n"DNS role installation completed. Proceeding with DC Promotion." 
    }
}
else {
    Write-Host `n"DNS role already installed. Proceeding with DC Promotion." 
}

if ($DHCPResponse -eq "Y"){
    Write-Host `n"Checking DHCP installation state..." -ForegroundColor DarkGreen
    $InstalledState = (Get-WindowsFeature -Name DHCP).installstate
    if ($InstalledState -ne "Installed"){
        Write-Host `n"Installing DHCP role... Please wait..." 
        Install-WindowsFeature -Name DHCP 
        Start-Sleep -Seconds 3

        $InstalledStateCheck = (Get-WindowsFeature -Name DHCP).installstate

        if ($InstalledStateCheck -ne "Installed"){
            Write-Warning "DHCP role installation failed. Please check logs or install manually."
        }
        elseif ($InstalledStateCheck -eq "Installed") {
            Write-Host `n"DHCP role installation completed. Proceeding with DC Promotion."
    
    }
    elseif ($InstalledState -eq "Installed") {
        Write-Host "DHCP role already installed. Proceeding with DC Promotion."
        }
    }
}
elseif ($DHCPResponse -eq "N"){
    Out-Null
}

Import-Module ADDSDeployment
Import-Module ActiveDirectory

Do {
    $ReplicationPartner = Read-Host "Enter the FQDN of the replication partner DC: "

    $NSlookup = nslookup $ReplicationPartner
    $NewNSLookup = $NSlookup -split ":"
    $FinalData = ($NewNSLookup[6]) -replace " ", ""

    If ($FinalData -ne $ReplicationPartner) {
        Write-Host `n 
        Write-Warning "You entered an invalid Domain Controller." 
        Write-Host "Please re-enter the replication partner name."
        Write-Host `n 
    }
}
Until ($FinalData -eq $ReplicationPartner)

$PSDefaultParameterValues = @{"*-AD*:Server"="$RepSourceDC"}
$Domains = Get-ADForest | select -ExpandProperty domains | sort
$Sites = Get-ADForest | select -ExpandProperty sites | sort

Do {
    Write-Host `n
    $DomainName = Read-Host "Please enter the domain FQDN where you wish to install the Domain Controller: "
    $DomainCheck = $Domains -contains $DomainName
        If ($DomainCheck -eq $false){
            Write-Host `n 
            Write-Warning "The domain name entered is invalid. Please re enter the domain name. "
        } 
        else {
            Write-Host `n 
            Write-Host "Selected Domain: $DomainName " -ForegroundColor Green
        }
    }
Until ($DomainCheck -eq $true)

Do {
    Write-Host `n
    $SiteName = Read-Host "Enter the site name for the Domain Controller: "
    $SiteCheck = $Sites -contains $SiteName
        if ($SiteCheck -eq $false){
            Write-Warning "Entered site name is invalid. Please re-enter the site name." 
        }
        else {
            Write-Host `n 
            Write-Host "The selected site is: $SiteName " -ForegroundColor Green
        }
    }
Until ($SiteCheck -eq $true)

$DSRMPassword = Read-Host "Enter the DSRM password: " -AsSecureString

$DBPath = "C:\Windows\NTDS"
$LogPath = "D:\Logs\Windows\NTDS"
$SYSVOLPath = "C:\Windows\SYSVOL"

Install-ADDSDomainController -InstallDns -DomainName $DomainName -Credential $Credentials -CreateDnsDelegation -SiteName $SiteName -ReplicationSourceDC $ReplicationPartner -DatabasePath $DBPath -LogPath $LogPath -SysvolPath $SYSVOLPath -SafeModeAdministratorPassword $DSRMPassword -Confirm
