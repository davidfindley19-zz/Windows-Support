<#
.SYNOPSIS
    Scripted restart of services.
.DESCRIPTION
    Prompts for a service and checks if the service is valid. Then prompts if you want to restart it.
    If the service isn't running, it asks if you want to start it.
.NOTES
    Author: David Findley
    Date: July 11, 2018
    Version: 1.0
.EXAMPLE
    You can call the script and then enter the name of the service after.
    C:\Get-Service.ps1 Spooler

    This will pull the information for the Print Spooler service and present your options.

.EXAMPLE
    You can also just call the script and it will prompt your for the service name.
    C:\Get-Service.ps1

    You will receive a mandatory prompt for the service name after starting the script.
#>

Param(
    [Parameter(Mandatory = $true, HelpMessage = "Enter the name of a service.")]
    [string]$Service
)

$Status = Get-Service "$Service"

if ($Status.Status -eq 'Running' ){
    $Response = Read-Host "Status is running. Would you like to restart the service? [Y]es or [N]o"
    switch ($Response) {
        Y {Write-Host "Ok, restarting the service $($Status.DisplayName) "; $Restart = $true }
        N {Write-Host "Ok, you have chosen not to restart $($Status.DisplayName). Exiting. "; $Restart = $false}
        Default {"Invalid Response. Exiting."; exit}
    }

}
else {
    $Response = Read-Host "$Status.DisplayName is not running. Would you like to start the service? [Y]es or [N]o"
    switch ($Response) {
        Y {Write-Host "Ok, restarting the service $($Status.DisplayName) "; $Start = $true }
        N {Write-Host "Ok, you have chosen to leave the service stopped. "; $Start = $false}
        Default {"Invalid Response. Exiting."; exit}
    }
}

if ($Restart -eq $true){
    Restart-Service $Status
    Write-host "$($Status.DisplayName) is now $($Status.Status). "
}
else {
    exit
}

if ($Start -eq $true){
    Start-Service $Status
    Write-host "$($Status.DisplayName) is now $($Status.Status). "
}
else {
    exit
}