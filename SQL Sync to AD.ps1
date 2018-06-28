<#
.SYNOPSIS
Nightly sync for Horizon SQL DB to Active Directory.
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
$Project = Invoke-Sqlcmd -Query "SELECT * FROM dbo.ProjectMembers ORDER BY Name" -Database $Database -ServerInstance $ServerInstance | Select-Object Name
$User = Invoke-Sqlcmd -Query "SELECT * FROM dbo.ProjectMembers ORDER BY Name" -Database $Database -ServerInstance $ServerInstance | Select-Object ObjectGUID

Out-File -FilePath C:\Users\Projects.csv -InputObject $Project $User -Encoding ascii -NoTypeInformation

$DestinationOU = "OU=SomeOUName,DC=Server,DC=local"
$GroupLines = Import-Csv -Path C:\Users\Projects.csv
Foreach ($GroupLine in $GroupLines) {
    TRY {Get-ADGroup $GroupLine.Name}
    CATCH {New-ADGroup -Name $GroupLine.Name -SamAccountName (($GroupLine.Name).Replace(" ", "")) -GroupCategory Distribution -GroupScope Universal -DisplayName $GroupLine.Name -Path $DestinationOU}
    }

Add-ADGroupMember -Identity $GroupLine.Name -Members $GroupLine.ObjectGUID