<#
.SYNOPSIS
Nightly sync for SQL DB to Active Directory.
.DESCRIPTION
Pulls the tables from SQL and matches users in the project to the corresponding groups in AD>
.NOTES
Author: David Findley
Date: 06/28/2018
Version: v1.0
#>

Import-Module ActiveDirectory -ErrorAction Stop

$ServerInstance = "SERVER\INSTANCE"
$Database = "DB NAME"
$Query = Invoke-Sqlcmd -Query "TYPE YOUR QUERY HERE" -Database $Database -ServerInstance $ServerInstance

Out-File -FilePath C:\Users\Projects.csv -InputObject $Query -Encoding ascii 

$DestinationOU = "OU=SomeOUName,DC=Server,DC=local"
$GroupLines = Import-Csv -Path C:\Users\Projects.csv

Foreach ($GroupLine in $GroupLines) {
    try {
        Get-ADGroup $GroupLine.Name
    }
    catch {
        New-ADGroup -Name $GroupLine.Name -SamAccountName $GroupLine.Name -GroupCategory Distribution -GroupScope Universal -DisplayName $GroupLine.Name -Path $DestinationOU
    }
    Add-ADGroupMember -Identity $GroupLine.Name -Members $GroupLine.ObjectGUID
}

