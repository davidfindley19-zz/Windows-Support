<#
.SYNOPSIS
    Enables PS Remoting on a remote computer.
.DESCRIPTION
    Prompts for a computer name and then enables the service on the computer. 
.NOTES
    Author: David Findley
    Date: 7/19/2018
    Version: 1.0
#>

Param(
    [Parameter(Mandatory = $true)]
    [string]$AdminUsername,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the computer that needs the service enabled.")]
    [string]$TargetMachine
)

# We needs to grab the credentials of an administrator on the remote computer.
$AdminPassword = Read-Host -AsSecureString "Enter your password: "
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminUsername , $AdminPassword


Invoke-WmiMethod -ComputerName $TargetMachine -Namespace root\cimv2 -Class Win32_Process -Name Create -Credential $Credentials -Impersonation 3 -EnableAllPrivileges `
-ArgumentList "powershell Start-Process powershell -Verb runAs -ArgumentList 'Enable-PSRemoting -force'"
